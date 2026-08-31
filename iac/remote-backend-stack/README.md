# 🪣 OCI Terraform - Stack 1: Remote Backend (Object Storage)

This stack creates an **OCI Object Storage Bucket** (Always Free - 20GB) to securely store the `terraform.tfstate` remote state file in Oracle Cloud.

---

## 🚀 How to Run

### 1. Configure `terraform.tfvars`
Navigate to `iac/remote-backend-stack` and copy the example configuration:

```bash
cd iac/remote-backend-stack
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your OCI credentials:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaaxxxxxx"
fingerprint      = "bf:f4:0e:a8:42:fa:b1:f9:f5:ff:65:66:1e:bf:c8:a8"
private_key_path = "~/.ssh/oci_api_key.pem"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaaxxxxxx"
region           = "us-ashburn-1"
bucket_name      = "<your-tfstate-bucket-name>"
```

### 2. Apply the Stack
```bash
terraform init
terraform apply
```

Upon completion, it will output `bucket_name`, `bucket_namespace`, and `s3_endpoint`.
