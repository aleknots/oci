# ☸️ Cluster Kubernetes Multi-Nó Nativo (Oracle Linux 9) Subnet Privada + Bastion Host no Oracle Cloud

Este projeto Terraform provisiona automaticamente um **Cluster Kubernetes Nativo de 3 Nós 100% Privado** + **1 Bastion Host (Jump Box)** executando no **Oracle Linux 9 (OL9)** na **Oracle Cloud Infrastructure (OCI)**, utilizando **100% do nível Always Free**:

| Nome da Instância (Hostname) | Função | Shape / Arq | OCPUs | RAM | Subnet | IP | SO |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `srv-bst-01` | Bastion Host (Jump Box) | `VM.Standard.E2.1.Micro` (AMD) | 1 OCPU | 1 GB | Pública | `10.0.1.5` (+Público) | Oracle Linux 9 |
| `srv-k8s-01` | Control Plane (Nó Master) | `VM.Standard.A1.Flex` (ARM) | 2 OCPUs | 8 GB | Privada | `10.0.2.11` (Privado) | Oracle Linux 9 |
| `srv-k8s-02` | Nó Worker 01 | `VM.Standard.A1.Flex` (ARM) | 1 OCPU | 8 GB | Privada | `10.0.2.12` (Privado) | Oracle Linux 9 |
| `srv-k8s-03` | Nó Worker 02 | `VM.Standard.A1.Flex` (ARM) | 1 OCPU | 8 GB | Privada | `10.0.2.13` (Privado) | Oracle Linux 9 |
| **TOTAL** | **4 VMs** | **1 AMD Micro + 3 ARM Flex** | **5 OCPUs** | **25 GB** | - | - | **Always Free ($ 0.00)** |

> 🛡️ **Segurança Máxima**: Todos os 3 nós do Kubernetes (`srv-k8s-01`, `srv-k8s-02`, `srv-k8s-03`) estão **100% isolados na Subnet Privada (`10.0.2.0/24`)**, sem endereços IP públicos diretos. O tráfego de saída (atualizações do sistema/pacotes) é roteado através de um **NAT Gateway**, e o acesso SSH é realizado exclusivamente via **ProxyJump no Bastion Host (`srv-bst-01`)** utilizando o usuário padrão **`opc`**.

---

## 🛠️ Métodos de Execução

### 💻 Método A: Execução no Terminal Local

No seu terminal, navegue até a pasta da stack e execute o Terraform:

```bash
cd iac/main-stack

# 1. Visualize as alterações de infraestrutura planejadas
terraform plan

# 2. Aplique e crie/atualize os recursos no Oracle Cloud
terraform apply
```

---

### 🤖 Método B: CI/CD Automatizado via GitHub Actions (GitOps)

Para habilitar a automação no GitHub Actions, cadastre as seguintes **Repository Secrets** em **Settings > Secrets and variables > Actions** no seu repositório GitHub:

| Secret | Descrição | Exemplo |
| :--- | :--- | :--- |
| `OCI_TENANCY_OCID` | OCID do seu Tenancy OCI | `ocid1.tenancy.oc1..aaaaaaaaxxxxxx` |
| `OCI_USER_OCID` | OCID do Usuário IAM | `ocid1.user.oc1..aaaaaaaaxxxxxx` |
| `OCI_FINGERPRINT` | Fingerprint da Chave de API RSA | `bf:f4:0e:a8:42:fa:b1:f9:f5:...` |
| `OCI_PRIVATE_KEY` | Conteúdo da Chave Privada da API RSA (.pem) | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `OCI_COMPARTMENT_OCID` | OCID do Compartimento Alvo | `ocid1.compartment.oc1..aaaaaaaaxxxxxx` |
| `OCI_REGION` | (Opcional) Região OCI (Padrão: `us-ashburn-1`) | `us-ashburn-1` ou `sa-saopaulo-1` |
| `SSH_PUBLIC_KEY` | Conteúdo da sua chave pública SSH (`cat ~/.ssh/id_rsa.pub`) | `ssh-rsa AAAAB3NzaC1yc2E...` |

> ⚠️ **Nota Importante sobre `SSH_PUBLIC_KEY`**: O secret `SSH_PUBLIC_KEY` deve conter o conteúdo do seu arquivo de chave pública (ex: `cat ~/.ssh/id_rsa.pub`) no **formato OpenSSH** (linha única começando com `ssh-rsa` ou `ssh-ed25519`). **NÃO** utilize o formato PEM (`-----BEGIN PUBLIC KEY-----`), pois o cloud-init do OCI irá rejeitá-lo com `Error: 400-InvalidParameter, Invalid ssh public key type "-----BEGIN"`.

#### Fluxo de Execução da Pipeline:
1. **Via Pull Request**:
   * Abrir um Pull Request para a branch `main` dispara automaticamente o `terraform plan` e publica a saída nos logs do workflow.

2. **Via Commit na `main` ou Disparo Manual**:
   * O merge na `main` (ou disparo manual em **Actions > Terraform OCI (Plan, Apply, Destroy) > Run workflow**) executa `terraform apply` ou `terraform destroy` diretamente no Oracle Cloud!

---

## 🔑 Acessando VMs Privadas via SSH ProxyJump (usuário `opc`)

Após executar o `terraform apply` (localmente ou via GitHub Actions), conecte-se às instâncias privadas através do Bastion Host utilizando um único comando:

```bash
# Conectar ao Bastion Host
ssh opc@<IP_PUBLICO_BASTION>

# Conectar ao Control Plane (srv-k8s-01) via ProxyJump
ssh -J opc@<IP_PUBLICO_BASTION> opc@10.0.2.11

# Conectar ao Nó Worker 01 (srv-k8s-02) via ProxyJump
ssh -J opc@<IP_PUBLICO_BASTION> opc@10.0.2.12

# Conectar ao Nó Worker 02 (srv-k8s-03) via ProxyJump
ssh -J opc@<IP_PUBLICO_BASTION> opc@10.0.2.13
```

---

## 🚀 Automação Pós-Terraform via Roles do Ansible

Após a criação das instâncias no Oracle Cloud (via `terraform apply` ou GitHub Actions), execute o playbook do Ansible para instalar o Kubernetes nativo (`systemd`), Flannel CNI, `k9s`, `argocd`, `helm`, `mongosh` e todo o conjunto de ferramentas SRE no Oracle Linux 9.

### Início Rápido:
1. Obtenha o IP público do Bastion Host a partir da saída do Terraform (`bastion_public_ip`).
2. Navegue até o repositório Ansible em [`ansible/deploy`](../../../ansible/deploy):
   ```bash
   cd ansible/deploy
   cp inventory-oci.ini.example inventory-oci.ini
   ```
3. Edite o `inventory-oci.ini` substituindo `<IP_PUBLICO_BASTION>` pelo IP público real.
4. Teste a conectividade e execute o playbook de Roles do Ansible:
   ```bash
   ansible all -i inventory-oci.ini -m ping

   # Playbook dedicado:
   ansible-playbook k8s-cluster-oci.yml -i inventory-oci.ini

   # Ou via ponto de entrada site.yml:
   ansible-playbook site.yml -i inventory-oci.ini --tags k8s
   ```

Para ver a documentação completa, consulte [`ansible/README.md`](../../../ansible/README.md).
