#!/usr/bin/env bash
# ==============================================================================
# Script de Limpeza Total e Destruição de Infraestrutura no Oracle Cloud (OCI)
# Uso: bash iac/scripts/destroy-all.sh
# ==============================================================================

set -e

echo "🚀 [OCI CLEANUP] Iniciando limpeza total da infraestrutura no OCI..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# 1. Executa terraform destroy nas stacks se terraform.tfvars existir
if [ -d "${REPO_ROOT}/iac/main-stack" ]; then
    echo "🧹 [1/3] Executando terraform destroy no main-stack..."
    if [ -f "${REPO_ROOT}/iac/main-stack/terraform.tfvars" ]; then
        (cd "${REPO_ROOT}/iac/main-stack" && terraform init -input=false 2>/dev/null || true && terraform destroy -auto-approve || true)
    else
        echo "ℹ️  ${REPO_ROOT}/iac/main-stack/terraform.tfvars não encontrado. Pulando terraform destroy para o main-stack."
    fi
fi

if [ -d "${REPO_ROOT}/iac/remote-backend-stack" ]; then
    echo "🧹 [2/3] Executando terraform destroy no remote-backend-stack..."
    if [ -f "${REPO_ROOT}/iac/remote-backend-stack/terraform.tfvars" ]; then
        (cd "${REPO_ROOT}/iac/remote-backend-stack" && terraform init -input=false 2>/dev/null || true && terraform destroy -auto-approve || true)
    else
        echo "ℹ️  ${REPO_ROOT}/iac/remote-backend-stack/terraform.tfvars não encontrado. Pulando terraform destroy para o remote-backend-stack."
    fi
fi

# 2. Verifica a disponibilidade do Python3 para limpeza de recursos órfãos via OCI SDK
if ! command -v python3 &> /dev/null; then
    echo "⚠️ Python3 não encontrado no sistema. Finalizando destruição via Terraform."
    exit 0
fi

# Instala a biblioteca oci se necessário
python3 -c "import oci" 2>/dev/null || {
    echo "📦 Instalando SDK Python da OCI (oci)..."
    pip install --break-system-packages oci six 2>/dev/null || pip install oci six 2>/dev/null || true
}

echo "🧹 [3/3] Verificando recursos órfãos remanescentes via Python OCI SDK..."

python3 - << EOF
import os
import sys
import re
import time

try:
    import oci
except ImportError:
    print("⚠️ OCI Python SDK not installed. Skipping SDK cleanup scan.")
    sys.exit(0)

def parse_tfvars(filepath):
    vars_dict = {}
    if not os.path.exists(filepath):
        return vars_dict
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            m = re.match(r'^\s*([a-zA-Z0-9_]+)\s*=\s*"([^"]+)"', line)
            if m:
                vars_dict[m.group(1)] = m.group(2)
    return vars_dict

config = None
compartment_id = None

tfvars_paths = [
    os.path.join("${REPO_ROOT}", "iac", "main-stack", "terraform.tfvars"),
    os.path.join("${REPO_ROOT}", "iac", "remote-backend-stack", "terraform.tfvars")
]

for tf_path in tfvars_paths:
    tf_data = parse_tfvars(tf_path)
    if "tenancy_ocid" in tf_data and "user_ocid" in tf_data and "private_key_path" in tf_data and "fingerprint" in tf_data:
        key_path = os.path.expanduser(tf_data["private_key_path"])
        if os.path.exists(key_path):
            config = {
                "user": tf_data["user_ocid"],
                "key_file": key_path,
                "fingerprint": tf_data["fingerprint"],
                "tenancy": tf_data["tenancy_ocid"],
                "region": tf_data.get("region", "us-ashburn-1")
            }
            compartment_id = tf_data.get("compartment_ocid", tf_data["tenancy_ocid"])
            print(f"🔑 Credentials loaded from {tf_path}")
            break

if not config:
    oci_config_file = os.path.expanduser("~/.oci/config")
    if os.path.exists(oci_config_file):
        try:
            config = oci.config.from_file(oci_config_file, "DEFAULT")
            compartment_id = config.get("tenancy")
            print(f"🔑 Credentials loaded from {oci_config_file}")
        except Exception as e:
            print(f"⚠️ Unable to read {oci_config_file}: {e}")

if not config:
    print("ℹ️ No OCI credentials (terraform.tfvars or ~/.oci/config) found for SDK cleanup.")
    sys.exit(0)

try:
    compute_client = oci.core.ComputeClient(config)
    net_client = oci.core.VirtualNetworkClient(config)
    object_storage_client = oci.object_storage.ObjectStorageClient(config)
except Exception as e:
    print(f"❌ Error initializing OCI SDK clients: {e}")
    sys.exit(0)

try:
    namespace = object_storage_client.get_namespace().data
except Exception as e:
    namespace = None

print(f"🔍 Checking active VM instances in compartment {compartment_id}...")
try:
    response = compute_client.list_instances(compartment_id=compartment_id)
    active_instances = [inst for inst in response.data if inst.lifecycle_state not in ["TERMINATED"]]

    if active_instances:
        print(f"🔥 Terminating {len(active_instances)} active instances...")
        for inst in active_instances:
            print(f"   -> Terminating VM: {inst.display_name} ({inst.id})...")
            try:
                compute_client.terminate_instance(instance_id=inst.id, preserve_boot_volume=False)
            except Exception as e:
                print(f"      Warning: {e}")

        print("⏳ Waiting for VM termination completion...")
        while True:
            res = compute_client.list_instances(compartment_id=compartment_id)
            still_running = [i for i in res.data if i.lifecycle_state != "TERMINATED"]
            if not still_running:
                print("✅ All instances terminated successfully!")
                break
            time.sleep(10)
    else:
        print("✅ No active instances found.")
except Exception as e:
    print(f"⚠️ Error listing/terminating instances: {e}")

print("\n🧹 Cleaning up VCNs and Virtual Networks...")
try:
    vcns = net_client.list_vcns(compartment_id=compartment_id).data

    for vcn in vcns:
        print(f"🔎 Processing VCN: {vcn.display_name} ({vcn.id})")
        
        subnets = net_client.list_subnets(compartment_id=compartment_id, vcn_id=vcn.id).data
        for s in subnets:
            print(f"   -> Deleting Subnet {s.display_name}...")
            try:
                net_client.delete_subnet(subnet_id=s.id)
            except Exception as e:
                print(f"      Warning: {e}")

        time.sleep(3)

        rts = net_client.list_route_tables(compartment_id=compartment_id, vcn_id=vcn.id).data
        for rt in rts:
            if rt.id != vcn.default_route_table_id:
                try:
                    net_client.update_route_table(
                        rt_id=rt.id,
                        update_route_table_details=oci.core.models.UpdateRouteTableDetails(route_rules=[])
                    )
                except Exception as e:
                    pass

        time.sleep(3)

        for ng in net_client.list_nat_gateways(compartment_id=compartment_id, vcn_id=vcn.id).data:
            try:
                net_client.delete_nat_gateway(nat_gateway_id=ng.id)
            except Exception as e:
                pass

        for ig in net_client.list_internet_gateways(compartment_id=compartment_id, vcn_id=vcn.id).data:
            try:
                net_client.delete_internet_gateway(ig_id=ig.id)
            except Exception as e:
                pass

        time.sleep(3)

        for rt in rts:
            if rt.id != vcn.default_route_table_id:
                try:
                    net_client.delete_route_table(rt_id=rt.id)
                except Exception as e:
                    pass

        for sl in net_client.list_security_lists(compartment_id=compartment_id, vcn_id=vcn.id).data:
            if sl.id != vcn.default_security_list_id:
                try:
                    net_client.delete_security_list(security_list_id=sl.id)
                except Exception as e:
                    pass

        time.sleep(3)

        try:
            net_client.delete_vcn(vcn_id=vcn.id)
            print(f"✅ VCN {vcn.display_name} destroyed successfully!")
        except Exception as e:
            print(f"❌ VCN Error: {e}")
except Exception as e:
    print(f"⚠️ Error listing/deleting VCNs: {e}")

if namespace:
    print("\n📦 Cleaning up Object Storage (Buckets)...")
    try:
        buckets = object_storage_client.list_buckets(namespace_name=namespace, compartment_id=compartment_id).data

        for b in buckets:
            print(f"🔎 Cleaning Bucket {b.name}...")
            try:
                objects = object_storage_client.list_objects(namespace_name=namespace, bucket_name=b.name).data.objects
                for obj in objects:
                    object_storage_client.delete_object(namespace_name=namespace, bucket_name=b.name, object_name=obj.name)
            except Exception as e:
                pass
            
            try:
                object_storage_client.delete_bucket(namespace_name=namespace, bucket_name=b.name)
                print(f"✅ Bucket {b.name} deleted successfully!")
            except Exception as e:
                print(f"❌ Error deleting bucket {b.name}: {e}")
    except Exception as e:
        print(f"⚠️ Error listing/deleting buckets: {e}")

print("\n==============================================")
print("🎉 OCI CLEANUP PROCESS COMPLETED!")
print("==============================================")
EOF
