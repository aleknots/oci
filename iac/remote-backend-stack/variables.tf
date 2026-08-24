variable "tenancy_ocid" {
  type        = string
  description = "OCID do Tenancy no Oracle Cloud"
}

variable "user_ocid" {
  type        = string
  description = "OCID do Usuário no Oracle Cloud"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint da Chave de API RSA"
}

variable "private_key_path" {
  type        = string
  description = "Caminho para a chave privada local da API RSA (.pem)"
  default     = "~/.ssh/oci_api_key.pem"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID do Compartimento Alvo"
}

variable "region" {
  type        = string
  description = "Região do Oracle Cloud"
  default     = "us-ashburn-1"
}

variable "bucket_name" {
  type        = string
  description = "Nome do Bucket do Object Storage para o Remote State do Terraform"
  default     = "iac-tfstate-bucket"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Caminho para a chave pública SSH"
  default     = "~/.ssh/id_rsa.pub"
}
