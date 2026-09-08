# ------------------------------------------------------------------------------
# OCI RESOURCE SCHEDULER (Agendamentos Automáticos de Inicialização / Parada)
# ------------------------------------------------------------------------------

# 1. Política IAM necessária para o serviço OCI Resource Scheduler
# Nota: O padrão é false via var.create_scheduler_policy porque credenciais de API da pipeline 
# geralmente não possuem permissão de criação de políticas IAM (404-NotAuthorizedOrNotFound).
# Crie esta política manualmente no Console da OCI se ainda não estiver presente:
# "Allow service resource-scheduler to manage instance-family in compartment id <COMPARTMENT_OCID>"
resource "oci_identity_policy" "resource_scheduler_policy" {
  count          = (var.enable_resource_scheduler && var.create_scheduler_policy) ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = "resource-scheduler-policy"
  description    = "Allows OCI Resource Scheduler service to manage compute instances"

  statements = [
    "Allow service resource-scheduler to manage instance-family in compartment id ${var.compartment_ocid}"
  ]
}

# 2. Agendamento para INICIAR instâncias de computação diariamente às 08:30 BRT
resource "oci_resource_scheduler_schedule" "start_instances_schedule" {
  count              = var.enable_resource_scheduler ? 1 : 0
  action             = "START_RESOURCE"
  compartment_id     = var.compartment_ocid
  display_name       = "sched-start-vms-0830-brt"
  description        = "Schedule to start all stack compute instances daily at 08:30 BRT"
  recurrence_type    = "CRON"
  recurrence_details = var.scheduler_start_cron
  local_time_zone    = var.scheduler_time_zone

  resources {
    id = oci_core_instance.srv_bst_01.id
  }

  resources {
    id = oci_core_instance.srv_k8s_01.id
  }

  dynamic "resources" {
    for_each = oci_core_instance.srv_k8s_worker
    content {
      id = resources.value.id
    }
  }
}

# 3. Agendamento para PARAR instâncias de computação diariamente às 18:30 BRT
resource "oci_resource_scheduler_schedule" "stop_instances_schedule" {
  count              = var.enable_resource_scheduler ? 1 : 0
  action             = "STOP_RESOURCE"
  compartment_id     = var.compartment_ocid
  display_name       = "sched-stop-vms-1830-brt"
  description        = "Schedule to stop all stack compute instances daily at 18:30 BRT"
  recurrence_type    = "CRON"
  recurrence_details = var.scheduler_stop_cron
  local_time_zone    = var.scheduler_time_zone

  resources {
    id = oci_core_instance.srv_bst_01.id
  }

  resources {
    id = oci_core_instance.srv_k8s_01.id
  }

  dynamic "resources" {
    for_each = oci_core_instance.srv_k8s_worker
    content {
      id = resources.value.id
    }
  }
}
