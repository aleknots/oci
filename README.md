# 🌩️ Oracle Cloud Infrastructure (OCI) - IaC & Automações

[![Terraform OCI (Plan, Apply, Destroy)](https://github.com/aleknots/oci/actions/workflows/provisioning-iac-oci.yml/badge.svg)](https://github.com/aleknots/oci/actions/workflows/provisioning-iac-oci.yml)
[![YAML Lint & Syntax Validation](https://github.com/aleknots/oci/actions/workflows/yaml-lint.yml/badge.svg?branch=main)](https://github.com/aleknots/oci/actions/workflows/yaml-lint.yml)
![Terraform](https://img.shields.io/badge/Terraform-v1.5.7-844FBA?logo=terraform&logoColor=white)
![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-Always%20Free-F80000?logo=oracle&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.31-326CE5?logo=kubernetes&logoColor=white)
![Licença](https://img.shields.io/badge/License-MIT-green.svg)

Este repositório contém código de Infraestrutura como Código (IaC) escrito em **Terraform**, organizado em uma arquitetura de **2 Stacks Independentes** para **Oracle Cloud Infrastructure (OCI)**.

---

## 📁 Estrutura do Repositório

```text
oci/
├── .github/workflows/
│   └── provisioning-iac-oci.yml # Pipeline CI/CD GitOps (GitHub Actions)
│
├── iac/                        # 🛠️ Infraestrutura como Código (Terraform)
│   ├── remote-backend-stack/  # Stack 1: Provisiona o Bucket no Object Storage para o tfstate remoto
│   └── main-stack/            # Stack 2: Cluster K8s Privado de 3 Nós + Bastion Host (Always Free)
│
├── .gitignore                  # Regras do Git (ignora .tfvars, .tfstate e *.lock.hcl)
└── README.md                   # Documentação oficial do repositório
```

---

## 🛠️ Arquitetura de Stacks (`iac/`)

O código de automação está separado na pasta **`iac/`** em 2 stacks independentes para garantir a idempotência e evitar dependências circulares de estado:

1. **`iac/remote-backend-stack/`**:
   * **Objetivo**: Cria um **Bucket no OCI Object Storage** (Always Free - 20GB) para armazenar o arquivo `terraform.tfstate` remotamente com versionamento habilitado.
   * **Ordem de Execução**: Deve ser executada **primeiro**.

2. **`iac/main-stack/`**:
   * **Objetivo**: Provisiona um **Cluster Kubernetes Nativo de 3 Nós Privados** + **1 Bastion Host** executando no **Oracle Linux 9 (OL9)** (nível 100% Always Free: 4 OCPUs e 24GB de RAM ARM Flex + 1 OCPU AMD Micro).
   * **Ordem de Execução**: Deve ser executada **após** a criação do backend remoto.

---

## 🚀 Métodos de Execução (Terminal Local ou GitHub Actions)

### 💻 Método 1: Execução no Terminal Local

```bash
# 1. Clone o repositório e navegue até a stack desejada
cd iac/remote-backend-stack # ou cd iac/main-stack

# 2. Copie o arquivo de exemplo de variáveis e edite com seus valores
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 3. Inicialize e aplique o Terraform
terraform init
terraform plan
terraform apply
```

### ☸️ Próximo Passo: Automação do Cluster Kubernetes via Roles do Ansible

Após o `terraform apply` criar o Bastion e as 3 VMs no OCI, configure e instale o Kubernetes nativo e o conjunto de ferramentas SRE navegando até o projeto Ansible:

```bash
# 1. Navegue para o diretório do projeto Ansible
cd ../ansible/deploy

# 2. Copie o arquivo de exemplo de inventário do OCI
cp inventory-oci.ini.example inventory-oci.ini

# 3. Edite o inventory-oci.ini com o IP público do Bastion Host e execute
ansible-playbook k8s-cluster-oci.yml -i inventory-oci.ini
# Ou via ponto de entrada site.yml:
ansible-playbook site.yml -i inventory-oci.ini --tags k8s
```

---

### 🤖 Método 2: CI/CD Automatizado via GitHub Actions

O repositório inclui uma pipeline pré-configurada do GitHub Actions (`.github/workflows/provisioning-iac-oci.yml`).

#### Secrets do GitHub Actions Necessários
Para habilitar a automação no GitHub Actions, cadastre as seguintes **Repository Secrets** em **Settings > Secrets and variables > Actions**:

| Nome do Secret | Descrição | Exemplo |
| :--- | :--- | :--- |
| `OCI_TENANCY_OCID` | OCID do seu Tenancy OCI | `ocid1.tenancy.oc1..aaaaaaaaxxxxxx` |
| `OCI_USER_OCID` | OCID do Usuário IAM | `ocid1.user.oc1..aaaaaaaaxxxxxx` |
| `OCI_FINGERPRINT` | Fingerprint da Chave de API RSA | `bf:f4:0e:a8:42:fa:b1:f9:f5:...` |
| `OCI_PRIVATE_KEY` | Conteúdo da Chave Privada da API RSA (.pem) | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `OCI_COMPARTMENT_OCID` | OCID do Compartimento Alvo | `ocid1.compartment.oc1..aaaaaaaaxxxxxx` |
| `OCI_REGION` | (Opcional) Região OCI (Padrão: `us-ashburn-1`) | `us-ashburn-1` ou `sa-saopaulo-1` |
| `SSH_PUBLIC_KEY` | Conteúdo da sua chave pública SSH (`cat ~/.ssh/id_rsa.pub`) | `ssh-rsa AAAAB3NzaC1yc2E...` |

> ⚠️ **Nota Importante sobre `SSH_PUBLIC_KEY`**: O secret `SSH_PUBLIC_KEY` deve conter o conteúdo do seu arquivo de chave pública (ex: `cat ~/.ssh/id_rsa.pub`) no **formato OpenSSH** (linha única começando com `ssh-rsa` ou `ssh-ed25519`). Não utilize o formato PEM (`-----BEGIN PUBLIC KEY-----`), pois o OCI irá rejeitar com erro HTTP 400.

#### Fluxo de Execução da Pipeline:
* **Pull Request**: Dispara automaticamente o `terraform plan` em alterações na pasta `iac/**`.
* **Push para `main` / Disparo Manual**: Permite executar `terraform apply` ou `terraform destroy` em **Actions > Terraform OCI (Plan, Apply, Destroy) > Run workflow**.

---

## 🛡️ Segurança & Permissões IAM (Princípio do Menor Privilégio)

Seguindo as melhores práticas de DevSecOps, o usuário de automação (ex: `svc_terraform`) **não deve** pertencer ao grupo `Administrators`.

### 1. Grupo IAM
Crie um grupo dedicado na OCI em **Identity & Security > Groups**:
* **Nome do Grupo**: `TerraformGroup`
* **Membros**: Adicione o usuário `svc_terraform`.

### 2. Política IAM (Policy)
Crie uma Política na OCI em **Identity & Security > Policies** chamada `TerraformIaCPolicy` e adicione as seguintes declarações:

```text
Allow group TerraformGroup to read compartments in tenancy
Allow group TerraformGroup to manage virtual-network-family in tenancy
Allow group TerraformGroup to manage instance-family in tenancy
Allow group TerraformGroup to manage volume-family in tenancy
Allow group TerraformGroup to manage object-family in tenancy
```

---

## 📄 Licença

Distribuído sob a Licença MIT.
