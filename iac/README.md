# 🌩️ Oracle Cloud Infrastructure (OCI) - Arquitetura de Stacks Terraform

Este repositório está estruturado em **duas stacks independentes** seguindo as melhores práticas de SRE e DevSecOps:

```text
iac/
├── remote-backend-stack/  # Stack 1: Provisiona o Bucket no OCI Object Storage (Estado Remoto)
└── main-stack/            # Stack 2: Provisiona 3 VMs para K8s Nativo + Rede VCN + Bastion
```

---

## 🗂️ 1. `remote-backend-stack`
Cria um **Bucket no OCI Object Storage** (Always Free - 20GB) para armazenar o arquivo `terraform.tfstate` remotamente com versionamento habilitado.

### Como aplicar:
```bash
cd iac/remote-backend-stack

# 1. Configurar variáveis
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Aplicar
terraform init
terraform apply
```

Ao finalizar, exibe o `s3_endpoint` e o `bucket_name` criados.

---

## ☸️ 2. `main-stack`
Provisiona a infraestrutura completa do cluster Kubernetes de 3 nós (1 Master + 2 Workers) com **4 OCPUs e 24GB de RAM** (Always Free $0.00) juntamente com um Bastion Host dedicado.

### Como aplicar:
```bash
cd iac/main-stack

# 1. Configurar variáveis
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Aplicar
terraform init
terraform apply
```

---

## 🎯 Ordem de Execução Recomendada
1. Execute **`remote-backend-stack`** primeiro para criar o armazenamento de estado remoto.
2. Execute **`main-stack`** em seguida para provisionar a rede e o cluster de VMs completo!

---

## 🔐 Configuração do GitHub Actions (CI/CD)

Para executar a pipeline automatizada do GitHub Actions (`.github/workflows/provisioning-iac-oci.yml`), cadastre as seguintes **Repository Secrets** em **Settings > Secrets and variables > Actions**:

* `OCI_TENANCY_OCID`: OCID do Tenancy no Oracle Cloud.
* `OCI_USER_OCID`: OCID do Usuário IAM.
* `OCI_FINGERPRINT`: Fingerprint da Chave de API RSA.
* `OCI_PRIVATE_KEY`: Conteúdo da chave privada da API OCI (.pem).
* `OCI_COMPARTMENT_OCID`: OCID do Compartimento Alvo.
* `OCI_REGION`: (Opcional) Região OCI (Padrão: `us-ashburn-1`).
* `SSH_PUBLIC_KEY`: Conteúdo da sua chave pública SSH no formato OpenSSH (ex: `cat ~/.ssh/id_rsa.pub`).

---

## 🛡️ Permissões Mínimas de IAM (Policy)

O usuário de automação (ex: `svc_terraform`) deve pertencer ao `TerraformGroup` com as seguintes políticas IAM habilitadas na OCI:

```text
Allow group TerraformGroup to read compartments in tenancy
Allow group TerraformGroup to manage virtual-network-family in tenancy
Allow group TerraformGroup to manage instance-family in tenancy
Allow group TerraformGroup to manage volume-family in tenancy
Allow group TerraformGroup to manage object-family in tenancy
```
