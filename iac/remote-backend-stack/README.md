# 🪣 OCI Terraform - Stack 1: Remote Backend (Object Storage)

Esta stack cria um **Bucket no OCI Object Storage** (Always Free - 20GB) para armazenar com segurança o arquivo de estado remoto `terraform.tfstate` no Oracle Cloud.

---

## 🚀 Como Executar

### 1. Configurar `terraform.tfvars`
Navegue até `iac/remote-backend-stack` e copie a configuração de exemplo:

```bash
cd iac/remote-backend-stack
cp terraform.tfvars.example terraform.tfvars
```

Edite o `terraform.tfvars` com suas credenciais OCI:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaaxxxxxx"
fingerprint      = "bf:f4:0e:a8:42:fa:b1:f9:f5:ff:65:66:1e:bf:c8:a8"
private_key_path = "~/.ssh/oci_api_key.pem"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
region           = "us-ashburn-1"
bucket_name      = "<seu-nome-de-bucket-tfstate>"
```

### 2. Aplicar a Stack
```bash
terraform init
terraform apply
```

Ao finalizar, serão exibidos as saídas `bucket_name`, `bucket_namespace` e `s3_endpoint`.
