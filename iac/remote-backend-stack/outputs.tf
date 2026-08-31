output "bucket_name" {
  description = "Name of the created Object Storage Bucket"
  value       = oci_objectstorage_bucket.tf_state_bucket.name
}

output "bucket_namespace" {
  description = "Object Storage Namespace"
  value       = oci_objectstorage_bucket.tf_state_bucket.namespace
}

output "s3_endpoint" {
  description = "S3-Compatible Endpoint to use in Terraform S3 Backend Configuration"
  value       = "https://${oci_objectstorage_bucket.tf_state_bucket.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}
