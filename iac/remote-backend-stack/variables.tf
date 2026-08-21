variable "tenancy_ocid" {
  type        = string
  description = "OCID of the Oracle Cloud Tenancy"
}

variable "user_ocid" {
  type        = string
  description = "OCID of the Oracle Cloud User"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the RSA API Key"
}

variable "private_key_path" {
  type        = string
  description = "Path to the local RSA API private key (.pem)"
  default     = "~/.ssh/oci_api_key.pem"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID of the Target Compartment"
}

variable "region" {
  type        = string
  description = "Oracle Cloud Region"
  default     = "us-ashburn-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the Object Storage Bucket for Terraform Remote State"
  default     = "iac-tfstate-bucket"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}
