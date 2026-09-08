# 🌩️ Oracle Cloud Infrastructure (OCI) - Arquitetura de Stacks do Terraform

Este repositório está estruturado em **duas stacks independentes** seguindo as melhores práticas de SRE e DevSecOps:

```text
iac/
├── remote-backend-stack/  # Stack 1: Provisiona o Bucket no Object Storage da OCI (Estado Remoto)
└── main-stack/            # Stack 2: Provisiona 3 VMs Nativa K8s + Rede VCN + Bastion
```

---

## 🗂️ 1. `remote-backend-stack`
Cria um **Bucket no Object Storage da OCI** (Always Free - 20GB) para armazenar de forma segura o arquivo de estado remoto `terraform.tfstate` com versionamento habilitado.

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

Ao finalizar, ele exibe o `s3_endpoint` e `bucket_name` criados.

---

## ☸️ 2. `main-stack`
Provisiona a infraestrutura completa do cluster Kubernetes de 3 nós (1 Master + 2 Workers) com **4 OCPUs e 24GB de RAM** (Always Free $0,00), além de um Bastion Host dedicado.

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
1. Execute a **`remote-backend-stack`** primeiro para criar o armazenamento de estado remoto.
2. Execute a **`main-stack`** em seguida para provisionar toda a rede e o cluster de VMs!

---

## 🔐 Configuração do GitHub Actions (CI/CD)

Para executar a pipeline automatizada do GitHub Actions (`.github/workflows/provisioning-iac-oci.yml`), registre os seguintes **Repository Secrets** em **Settings > Secrets and variables > Actions**:

* `OCI_TENANCY_OCID`: OCID da Tenancy na Oracle Cloud.
* `OCI_USER_OCID`: OCID do Usuário IAM.
* `OCI_FINGERPRINT`: Fingerprint da Chave de API RSA.
* `OCI_PRIVATE_KEY`: Conteúdo da chave privada da API OCI (.pem).
* `OCI_COMPARTMENT_OCID`: OCID do Compartimento Alvo.
* `OCI_REGION`: (Opcional) Região OCI (Padrão: `us-ashburn-1`).
* `SSH_PUBLIC_KEY`: Conteúdo da sua chave pública SSH em formato OpenSSH (ex.: `cat ~/.ssh/id_rsa.pub`).

---

## 🛡️ Permissões Mínimas de IAM (Policy)

O usuário de automação (ex.: `svc_terraform`) deve pertencer ao grupo `TerraformGroup` com as seguintes políticas IAM habilitadas na OCI:

```text
Allow group TerraformGroup to read compartments in tenancy
Allow group TerraformGroup to manage virtual-network-family in tenancy
Allow group TerraformGroup to manage instance-family in tenancy
Allow group TerraformGroup to manage volume-family in tenancy
Allow group TerraformGroup to manage object-family in tenancy
Allow group TerraformGroup to manage resource-schedule-family in tenancy
Allow service resource_scheduler to manage instance-family in tenancy
```
