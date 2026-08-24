# Compartimento OCI e Autenticação
variable "tenancy_ocid" {
  type        = string
  description = "OCID do Tenancy OCI"
}

variable "user_ocid" {
  type        = string
  description = "OCID do Usuário OCI"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint da Chave de API RSA OCI"
}

variable "private_key_path" {
  type        = string
  description = "Caminho para a chave privada da API OCI"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID do Compartimento OCI"
}

variable "region" {
  type        = string
  description = "Região OCI"
  default     = "us-ashburn-1"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Caminho para a chave pública OpenSSH para acesso às instâncias Linux"
  default     = "~/.ssh/id_rsa.pub"
}

# Seleção de Sistema Operacional (Padrão: Oracle Linux 9 Nativo OCI)
variable "os_distribution" {
  type        = string
  description = "Distribuição do SO: 'Oracle Linux' (9)"
  default     = "Oracle Linux"
}

variable "os_version" {
  type        = string
  description = "Versão do SO"
  default     = "9"
}

# Bastion Host (AMD Micro Always Free)
variable "bastion_shape" {
  type        = string
  description = "Shape para o Bastion Host (AMD x86_64 Always Free)"
  default     = "VM.Standard.E2.1.Micro"
}

# Configuração de Hardware do Cluster Kubernetes (ARM Ampere A1 Always Free)
variable "instance_shape" {
  type        = string
  description = "Shape para os Nós do Cluster K8s (ARM Ampere A1 Flex Always Free)"
  default     = "VM.Standard.A1.Flex"
}

variable "master_ocpus" {
  type        = number
  description = "OCPUs para o Nó Master"
  default     = 2
}

variable "master_memory_in_gbs" {
  type        = number
  description = "RAM em GB para o Nó Master"
  default     = 8
}

variable "worker_count" {
  type        = number
  description = "Quantidade de Nós Worker"
  default     = 2
}

variable "worker_ocpus" {
  type        = number
  description = "OCPUs para cada Nó Worker"
  default     = 1
}

variable "worker_memory_in_gbs" {
  type        = number
  description = "RAM em GB para cada Nó Worker"
  default     = 8
}

variable "boot_volume_size_in_gbs" {
  type        = string
  description = "Tamanho do volume de boot em GB"
  default     = "50"
}
