# OCI Compartment and Authentication
variable "tenancy_ocid" {
  type        = string
  description = "OCID da Tenancy na OCI"
}

variable "user_ocid" {
  type        = string
  description = "OCID do Usuário na OCI"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint da Chave de API RSA da OCI"
}

variable "private_key_path" {
  type        = string
  description = "Caminho para a chave privada da API da OCI"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID do Compartimento na OCI"
}

variable "region" {
  type        = string
  description = "Região da OCI"
  default     = "us-ashburn-1"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Caminho para a chave pública OpenSSH de acesso às instâncias Linux"
  default     = "~/.ssh/id_rsa.pub"
}

# Operating System Selection (Default: Oracle Linux 9 Native OCI)
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

# Kubernetes Cluster Hardware Configuration (ARM Ampere A1 Always Free)
variable "instance_shape" {
  type        = string
  description = "Shape para os Nós do Cluster K8s (ARM Ampere A1 Flex Always Free)"
  default     = "VM.Standard.A1.Flex"
}

variable "master_ocpus" {
  type        = number
  description = "OCPUs para o Nó Master (Control Plane)"
  default     = 2
}

variable "master_memory_in_gbs" {
  type        = number
  description = "Memória RAM em GB para o Nó Master"
  default     = 8
}

variable "worker_count" {
  type        = number
  description = "Quantidade de Nós Workers"
  default     = 2
}

variable "worker_ocpus" {
  type        = number
  description = "OCPUs para cada Nó Worker"
  default     = 1
}

variable "worker_memory_in_gbs" {
  type        = number
  description = "Memória RAM em GB para cada Nó Worker"
  default     = 8
}

variable "boot_volume_size_in_gbs" {
  type        = string
  description = "Tamanho do volume de boot em GB"
  default     = "50"
}

# OCI Resource Scheduler Configuration
variable "enable_resource_scheduler" {
  type        = bool
  description = "Habilita os agendamentos automáticos de Inicialização / Parada via OCI Resource Scheduler."
  default     = true
}

variable "create_scheduler_policy" {
  type        = bool
  description = "Cria a política IAM via Terraform (defina como false se a política foi criada manualmente ou se o usuário da API não possui privilégios de criação de políticas IAM)."
  default     = false
}

variable "scheduler_time_zone" {
  type        = string
  description = "Fuso horário para o OCI Resource Scheduler (Padrão: America/Sao_Paulo)"
  default     = "America/Sao_Paulo"
}

variable "scheduler_start_cron" {
  type        = string
  description = "Expressão CRON para ligar as instâncias diariamente (Padrão: 08:30 BRT)"
  default     = "30 8 * * *"
}

variable "scheduler_stop_cron" {
  type        = string
  description = "Expressão CRON para desligar as instâncias diariamente (Padrão: 18:30 BRT)"
  default     = "30 18 * * *"
}
