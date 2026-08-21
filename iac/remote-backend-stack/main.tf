# Fetch OCI Tenancy Object Storage Namespace
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# Create Object Storage Bucket for Terraform Remote State (Always Free - 20GB)
resource "oci_objectstorage_bucket" "tf_state_bucket" {
  compartment_id = var.compartment_ocid
  name           = var.bucket_name
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = "Enabled"
}
