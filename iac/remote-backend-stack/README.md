# 🪣 OCI Terraform - Stack 1: Remote Backend (Object Storage)

Esta stack cria um **Bucket no Object Storage da OCI** (Always Free - 20GB) para armazenar com segurança o arquivo de estado remoto `terraform.tfstate` na Oracle Cloud.

---

## 🚀 Como Executar

### 1. Configurar o `terraform.tfvars`
Navegue até `iac/remote-backend-stack` e copie a configuração de exemplo:

```bash
cd iac/remote-backend-stack
cp terraform.tfvars.example terraform.tfvars
```

Edite o `terraform.tfvars` com suas credenciais da OCI:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaaxxxxxx"
fingerprint      = "bf:f4:0e:a8:42:fa:b1:f9:f5:ff:65:66:1e:bf:c8:a8"
private_key_path = "~/.ssh/oci_api_key.pem"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
region           = "us-ashburn-1"
bucket_name      = "<nome-do-seu-bucket-tfstate>"
```

### 2. Aplicar a Stack
```bash
terraform init
terraform apply
```

Ao finalizar, ele exibirá `bucket_name`, `bucket_namespace` e `s3_endpoint`.
