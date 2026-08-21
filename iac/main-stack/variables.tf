# OCI Compartment and Authentication
variable "tenancy_ocid" {
  type        = string
  description = "OCID of the OCI Tenancy"
}

variable "user_ocid" {
  type        = string
  description = "OCID of the OCI User"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the OCI RSA API Key"
}

variable "private_key_path" {
  type        = string
  description = "Path to the OCI API private key"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID of the OCI Compartment"
}

variable "region" {
  type        = string
  description = "OCI Region"
  default     = "us-ashburn-1"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the OpenSSH public key for Linux instance access"
  default     = "~/.ssh/id_rsa.pub"
}

# Operating System Selection (Default: Oracle Linux 9 Native OCI)
variable "os_distribution" {
  type        = string
  description = "OS Distribution: 'Oracle Linux' (9)"
  default     = "Oracle Linux"
}

variable "os_version" {
  type        = string
  description = "OS Version"
  default     = "9"
}

# Bastion Host (AMD Micro Always Free)
variable "bastion_shape" {
  type        = string
  description = "Shape for the Bastion Host (AMD x86_64 Always Free)"
  default     = "VM.Standard.E2.1.Micro"
}

# Kubernetes Cluster Hardware Configuration (ARM Ampere A1 Always Free)
variable "instance_shape" {
  type        = string
  description = "Shape for K8s Cluster Nodes (ARM Ampere A1 Flex Always Free)"
  default     = "VM.Standard.A1.Flex"
}

variable "master_ocpus" {
  type        = number
  description = "OCPUs for the Master Node"
  default     = 2
}

variable "master_memory_in_gbs" {
  type        = number
  description = "RAM in GB for the Master Node"
  default     = 8
}

variable "worker_count" {
  type        = number
  description = "Number of Worker Nodes"
  default     = 2
}

variable "worker_ocpus" {
  type        = number
  description = "OCPUs for each Worker Node"
  default     = 1
}

variable "worker_memory_in_gbs" {
  type        = number
  description = "RAM in GB for each Worker Node"
  default     = 8
}

variable "boot_volume_size_in_gbs" {
  type        = string
  description = "Boot volume size in GB"
  default     = "50"
}
