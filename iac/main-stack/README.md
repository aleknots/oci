# ☸️ Native Multi-Node Kubernetes Cluster (Oracle Linux 9) Private Subnet + Bastion Host on Oracle Cloud

This Terraform project automatically provisions a **100% Private 3-Node Native Kubernetes Cluster** + **1 Bastion Host (Jump Box)** running on **Oracle Linux 9 (OL9)** in **Oracle Cloud Infrastructure (OCI)**, leveraging **100% of the Always Free tier**:

| Instance Name (Hostname) | Role | Shape / Arch | OCPUs | RAM | Subnet | IP | OS |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `srv-bst-01` | Bastion Host (Jump Box) | `VM.Standard.E2.1.Micro` (AMD) | 1 OCPU | 1 GB | Public | `10.0.1.5` (+Public) | Oracle Linux 9 |
| `srv-k8s-01` | Control Plane (Master Node) | `VM.Standard.A1.Flex` (ARM) | 2 OCPUs | 8 GB | Private | `10.0.2.11` (Private) | Oracle Linux 9 |
| `srv-k8s-02` | Worker Node 01 | `VM.Standard.A1.Flex` (ARM) | 1 OCPU | 8 GB | Private | `10.0.2.12` (Private) | Oracle Linux 9 |
| `srv-k8s-03` | Worker Node 02 | `VM.Standard.A1.Flex` (ARM) | 1 OCPU | 8 GB | Private | `10.0.2.13` (Private) | Oracle Linux 9 |
| **TOTAL** | **4 VMs** | **1 AMD Micro + 3 ARM Flex** | **5 OCPUs** | **25 GB** | - | - | **Always Free ($ 0.00)** |

> 🛡️ **Maximum Security**: All 3 Kubernetes nodes (`srv-k8s-01`, `srv-k8s-02`, `srv-k8s-03`) are **100% isolated in the Private Subnet (`10.0.2.0/24`)**, without direct public IP addresses. Outbound traffic (system updates/packages) is routed through a **NAT Gateway**, and SSH access is exclusively performed via **Bastion Host ProxyJump (`srv-bst-01`)** using the default **`opc`** user.

---

## 🛠️ Execution Methods

### 💻 Method A: Local Terminal Execution

In your terminal, navigate to the stack folder and run Terraform:

```bash
cd iac/main-stack

# 1. Preview planned infrastructure changes
terraform plan

# 2. Apply and create/update resources on Oracle Cloud
terraform apply
```

---

### 🤖 Method B: Automated CI/CD via GitHub Actions (GitOps)

To enable GitHub Actions automation, register the following **Repository Secrets** under **Settings > Secrets and variables > Actions** in your GitHub repository:

| Secret | Description | Example |
| :--- | :--- | :--- |
| `OCI_TENANCY_OCID` | OCID of your OCI Tenancy | `ocid1.tenancy.oc1..aaaaaaaaxxxxxx` |
| `OCI_USER_OCID` | OCID of the IAM User | `ocid1.user.oc1..aaaaaaaaxxxxxx` |
| `OCI_FINGERPRINT` | Fingerprint of the RSA API Key | `bf:f4:0e:a8:42:fa:b1:f9:f5:...` |
| `OCI_PRIVATE_KEY` | Content of the RSA API Private Key (.pem) | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `OCI_COMPARTMENT_OCID` | OCID of the Target Compartment | `ocid1.compartment.oc1..aaaaaaaaxxxxxx` |
| `OCI_REGION` | (Optional) OCI Region (Default: `us-ashburn-1`) | `us-ashburn-1` or `sa-saopaulo-1` |
| `SSH_PUBLIC_KEY` | Content of your SSH public key (`cat ~/.ssh/id_rsa.pub`) | `ssh-rsa AAAAB3NzaC1yc2E...` |

> ⚠️ **Important Note on `SSH_PUBLIC_KEY`**: The `SSH_PUBLIC_KEY` secret must be the content of your public key file (e.g. `cat ~/.ssh/id_rsa.pub`) in **OpenSSH format** (single line starting with `ssh-rsa` or `ssh-ed25519`). **DO NOT** use the PEM format (`-----BEGIN PUBLIC KEY-----`), as OCI cloud-init will reject it with `Error: 400-InvalidParameter, Invalid ssh public key type "-----BEGIN"`.

#### Pipeline Execution Workflow:
1. **Via Pull Request**:
   * Opening a Pull Request against `main` automatically triggers `terraform plan` and posts the output to the workflow log.

2. **Via Commit to `main` or Manual Trigger**:
   * Merging to `main` (or triggering manually under **Actions > Terraform OCI (Plan, Apply, Destroy) > Run workflow**) runs `terraform apply` or `terraform destroy` directly on Oracle Cloud!

---

## 🔑 Accessing Private VMs via SSH ProxyJump (`opc` user)

After running `terraform apply` (locally or via GitHub Actions), connect to private instances through the Bastion Host using a single command:

```bash
# Connect to the Bastion Host
ssh opc@<PUBLIC_BASTION_IP>

# Connect to the Control Plane (srv-k8s-01) via ProxyJump
ssh -J opc@<PUBLIC_BASTION_IP> opc@10.0.2.11

# Connect to Worker Node 01 (srv-k8s-02) via ProxyJump
ssh -J opc@<PUBLIC_BASTION_IP> opc@10.0.2.12

# Connect to Worker Node 02 (srv-k8s-03) via ProxyJump
ssh -J opc@<PUBLIC_BASTION_IP> opc@10.0.2.13
```

---

## 🚀 Post-Terraform Automation via Ansible Roles

After instances are created on Oracle Cloud (via `terraform apply` or GitHub Actions), execute the Ansible playbook to install native Kubernetes (`systemd`), Flannel CNI, `k9s`, `argocd`, `helm`, `mongosh`, and the complete SRE toolset on Oracle Linux 9.

### Quick Start:
1. Retrieve the public IP of the Bastion Host from Terraform output (`bastion_public_ip`).
2. Navigate to the Ansible repository at [`ansible/deploy`](../../../ansible/deploy):
   ```bash
   cd ansible/deploy
   cp inventory-oci.ini.example inventory-oci.ini
   ```
3. Edit `inventory-oci.ini` replacing `<PUBLIC_BASTION_IP>` with the actual public IP.
4. Test connectivity and run the Ansible Roles playbook:
   ```bash
   ansible all -i inventory-oci.ini -m ping

   # Dedicated playbook:
   ansible-playbook k8s-cluster-oci.yml -i inventory-oci.ini

   # Or via site.yml entrypoint:
   ansible-playbook site.yml -i inventory-oci.ini --tags k8s
   ```

For full documentation, refer to [`ansible/README.md`](../../../ansible/README.md).
