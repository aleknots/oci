# 🌩️ Oracle Cloud Infrastructure (OCI) - Terraform Stacks Architecture

This repository is structured into **two independent stacks** following SRE and DevSecOps best practices:

```text
iac/
├── remote-backend-stack/  # Stack 1: Provisions OCI Object Storage Bucket (Remote State)
└── main-stack/            # Stack 2: Provisions 3 Native K8s VMs + VCN Network + Bastion
```

---

## 🗂️ 1. `remote-backend-stack`
Creates an **OCI Object Storage Bucket** (Always Free - 20GB) to store the `terraform.tfstate` file remotely with versioning enabled.

### How to apply:
```bash
cd iac/remote-backend-stack

# 1. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Apply
terraform init
terraform apply
```

Upon completion, it outputs the created `s3_endpoint` and `bucket_name`.

---

## ☸️ 2. `main-stack`
Provisions the complete 3-node Kubernetes cluster infrastructure (1 Master + 2 Workers) with **4 OCPUs and 24GB RAM** (Always Free $0.00) alongside a dedicated Bastion Host.

### How to apply:
```bash
cd iac/main-stack

# 1. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Apply
terraform init
terraform apply
```

---

## 🎯 Recommended Execution Order
1. Run **`remote-backend-stack`** first to create remote state storage.
2. Run **`main-stack`** next to provision the complete network and VM cluster!

---

## 🔐 GitHub Actions Configuration (CI/CD)

To run the automated GitHub Actions pipeline (`.github/workflows/provisioning-iac-oci.yml`), register the following **Repository Secrets** under **Settings > Secrets and variables > Actions**:

* `OCI_TENANCY_OCID`: OCID of the Oracle Cloud Tenancy.
* `OCI_USER_OCID`: OCID of the IAM User.
* `OCI_FINGERPRINT`: Fingerprint of the RSA API Key.
* `OCI_PRIVATE_KEY`: Content of the OCI API private key (.pem).
* `OCI_COMPARTMENT_OCID`: OCID of the Target Compartment.
* `OCI_REGION`: (Optional) OCI Region (Default: `us-ashburn-1`).
* `SSH_PUBLIC_KEY`: Content of your SSH public key in OpenSSH format (e.g. `cat ~/.ssh/id_rsa.pub`).

---

## 🛡️ Minimum IAM Permissions (Policy)

The automation user (e.g. `svc_terraform`) must belong to `TerraformGroup` with the following IAM policies enabled in OCI:

```text
Allow group TerraformGroup to read compartments in tenancy
Allow group TerraformGroup to manage virtual-network-family in tenancy
Allow group TerraformGroup to manage instance-family in tenancy
Allow group TerraformGroup to manage volume-family in tenancy
Allow group TerraformGroup to manage object-family in tenancy
```
