output "bucket_name" {
  description = "Nome do Bucket criado no Object Storage"
  value       = oci_objectstorage_bucket.tf_state_bucket.name
}

output "bucket_namespace" {
  description = "Namespace do Object Storage"
  value       = oci_objectstorage_bucket.tf_state_bucket.namespace
}

output "s3_endpoint" {
  description = "Endpoint compatível com S3 para uso na configuração do Backend S3 do Terraform"
  value       = "https://${oci_objectstorage_bucket.tf_state_bucket.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}
