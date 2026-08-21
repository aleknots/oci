# 🌩️ Oracle Cloud Infrastructure (OCI) - IaC & Automations

[![Terraform OCI (Plan, Apply, Destroy)](https://github.com/aleknots/oci/actions/workflows/provisioning-iac-oci.yml/badge.svg)](https://github.com/aleknots/oci/actions/workflows/provisioning-iac-oci.yml)
[![YAML Lint & Syntax Validation](https://github.com/aleknots/oci/actions/workflows/yaml-lint.yml/badge.svg?branch=main)](https://github.com/aleknots/oci/actions/workflows/yaml-lint.yml)
![Terraform](https://img.shields.io/badge/Terraform-v1.5.7-844FBA?logo=terraform&logoColor=white)
![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-Always%20Free-F80000?logo=oracle&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.31-326CE5?logo=kubernetes&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

This repository contains Infrastructure as Code (IaC) written in **Terraform** organized under a **2 Independent Stacks** architecture for **Oracle Cloud Infrastructure (OCI)**.

---

## 📁 Repository Structure

```text
oci/
├── .github/workflows/
│   └── provisioning-iac-oci.yml # CI/CD GitOps Pipeline (GitHub Actions)
│
├── iac/                        # 🛠️ Infrastructure as Code (Terraform)
│   ├── remote-backend-stack/  # Stack 1: Provisions Object Storage Bucket for remote tfstate
│   └── main-stack/            # Stack 2: Private 3-Node K8s Cluster + Bastion Host (Always Free)
│
├── .gitignore                  # Git rules (ignores .tfvars, .tfstate, and *.lock.hcl)
└── README.md                   # Official repository documentation
```

---

## 🛠️ Stacks Architecture (`iac/`)

Automation code is separated inside the **`iac/`** folder into 2 independent stacks to ensure idempotency and prevent circular state dependencies:

1. **`iac/remote-backend-stack/`**:
   * **Purpose**: Creates an **OCI Object Storage Bucket** (Always Free - 20GB) to store the `terraform.tfstate` file remotely with versioning enabled.
   * **Execution Order**: Must be executed **first**.

2. **`iac/main-stack/`**:
   * **Purpose**: Provisions a **Native 3-Private Node Kubernetes Cluster** + **1 Bastion Host** running on **Oracle Linux 9 (OL9)** (100% Always Free tier: 4 OCPUs and 24GB RAM ARM Flex + 1 OCPU AMD Micro).
   * **Execution Order**: Must be executed **after** remote backend creation.

---

## 🚀 Execution Methods (Local Terminal or GitHub Actions)

### 💻 Method 1: Local Terminal Execution

```bash
# 1. Clone the repository and navigate to the target stack
cd iac/remote-backend-stack # or cd iac/main-stack

# 2. Copy variable example file and edit with your values
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 3. Initialize and apply Terraform
terraform init
terraform plan
terraform apply
```

### ☸️ Next Step: Kubernetes Cluster Automation via Ansible Roles

After `terraform apply` creates the Bastion and the 3 VMs in OCI, configure and install native Kubernetes and the SRE toolset by navigating to the Ansible project:

```bash
# 1. Navigate to the Ansible project directory
cd ../ansible/deploy

# 2. Copy the example OCI inventory file
cp inventory-oci.ini.example inventory-oci.ini

# 3. Edit inventory-oci.ini with the Bastion Host public IP and execute
ansible-playbook k8s-cluster-oci.yml -i inventory-oci.ini
# Or via site.yml entrypoint:
ansible-playbook site.yml -i inventory-oci.ini --tags k8s
```

---

### 🤖 Method 2: Automated CI/CD via GitHub Actions

The repository includes a pre-configured GitHub Actions pipeline (`.github/workflows/provisioning-iac-oci.yml`).

#### Required GitHub Actions Secrets
To enable automation in GitHub Actions, register the following **Repository Secrets** under **Settings > Secrets and variables > Actions**:

| Secret Name | Description | Example |
| :--- | :--- | :--- |
| `OCI_TENANCY_OCID` | OCID of your OCI Tenancy | `ocid1.tenancy.oc1..aaaaaaaaxxxxxx` |
| `OCI_USER_OCID` | OCID of the IAM User | `ocid1.user.oc1..aaaaaaaaxxxxxx` |
| `OCI_FINGERPRINT` | Fingerprint of the RSA API Key | `bf:f4:0e:a8:42:fa:b1:f9:f5:...` |
| `OCI_PRIVATE_KEY` | Content of the RSA API Private Key (.pem) | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `OCI_COMPARTMENT_OCID` | OCID of the Target Compartment | `ocid1.compartment.oc1..aaaaaaaaxxxxxx` |
| `OCI_REGION` | (Optional) OCI Region (Default: `us-ashburn-1`) | `us-ashburn-1` or `sa-saopaulo-1` |
| `SSH_PUBLIC_KEY` | Content of your SSH public key (`cat ~/.ssh/id_rsa.pub`) | `ssh-rsa AAAAB3NzaC1yc2E...` |

> ⚠️ **Important Note on `SSH_PUBLIC_KEY`**: The `SSH_PUBLIC_KEY` secret must be the content of your public key file (e.g. `cat ~/.ssh/id_rsa.pub`) in **OpenSSH format** (single line starting with `ssh-rsa` or `ssh-ed25519`). Do not use the PEM format (`-----BEGIN PUBLIC KEY-----`), as OCI will reject it with HTTP 400 error.

#### Pipeline Workflow:
* **Pull Request**: Automatically triggers `terraform plan` on changes inside `iac/**`.
* **Push to `main` / Manual Trigger**: Allows running `terraform apply` or `terraform destroy` under **Actions > Terraform OCI (Plan, Apply, Destroy) > Run workflow**.

---

## 🛡️ Security & IAM Permissions (Principle of Least Privilege)

Following DevSecOps best practices, the automation user (e.g. `svc_terraform`) **should not** belong to the `Administrators` group.

### 1. IAM Group
Create a dedicated group in OCI under **Identity & Security > Groups**:
* **Group Name**: `TerraformGroup`
* **Members**: Add the user `svc_terraform`.

### 2. IAM Policy
Create a Policy in OCI under **Identity & Security > Policies** named `TerraformIaCPolicy` and add the following statements:

```text
Allow group TerraformGroup to read compartments in tenancy
Allow group TerraformGroup to manage virtual-network-family in tenancy
Allow group TerraformGroup to manage instance-family in tenancy
Allow group TerraformGroup to manage volume-family in tenancy
Allow group TerraformGroup to manage object-family in tenancy
```

---

## 📄 License

Distributed under the MIT License.
