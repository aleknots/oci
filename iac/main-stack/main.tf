# Availability Domains Lookup
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_ocid
}

# Automatic selection of compatible AD for AMD Micro shape (in us-ashburn-1 located in AD-3)
locals {
  bastion_ad = length(data.oci_identity_availability_domains.ad.availability_domains) >= 3 ? data.oci_identity_availability_domains.ad.availability_domains[2].name : data.oci_identity_availability_domains.ad.availability_domains[0].name
  k8s_ad     = data.oci_identity_availability_domains.ad.availability_domains[0].name
}

# ------------------------------------------------------------------------------
# DYNAMIC LOOKUP OF LATEST OFFICIAL OS IMAGE (Default: Oracle Linux 9)
# ------------------------------------------------------------------------------

# AMD x86_64 Image for Bastion Host (srv-bst-01)
data "oci_core_images" "srv_bst_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.os_distribution == "Ubuntu" ? "Canonical Ubuntu" : "Oracle Linux"
  operating_system_version = var.os_version
  shape                    = var.bastion_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ARM64 Image for Kubernetes Cluster Nodes (srv-k8s-01, 02, 03)
data "oci_core_images" "srv_k8s_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.os_distribution == "Ubuntu" ? "Canonical Ubuntu" : "Oracle Linux"
  operating_system_version = var.os_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ------------------------------------------------------------------------------
# 1. BASTION HOST (srv-bst-01: AMD x86_64 - VM.Standard.E2.1.Micro Always Free in AD-3)
# ------------------------------------------------------------------------------
resource "oci_core_instance" "srv_bst_01" {
  availability_domain = local.bastion_ad
  compartment_id      = var.compartment_ocid
  display_name        = "srv-bst-01"
  shape               = var.bastion_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.bastion_subnet.id
    assign_public_ip = true
    display_name     = "vnic-srv-bst-01"
    hostname_label   = "srv-bst-01"
    private_ip       = "10.0.1.5"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.srv_bst_image.images[0].id
    boot_volume_size_in_gbs = "50" # Minimum required size for Oracle Linux 9 images on OCI
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}

# ------------------------------------------------------------------------------
# 2. CONTROL PLANE / MASTER (srv-k8s-01: ARM64 2 OCPUs, 8GB RAM - Private Subnet)
# ------------------------------------------------------------------------------
resource "oci_core_instance" "srv_k8s_01" {
  availability_domain = local.k8s_ad
  compartment_id      = var.compartment_ocid
  display_name        = "srv-k8s-01"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.master_ocpus
    memory_in_gbs = var.master_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k8s_private_subnet.id
    assign_public_ip = false # 100% Private!
    display_name     = "vnic-srv-k8s-01"
    hostname_label   = "srv-k8s-01"
    private_ip       = "10.0.2.11"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.srv_k8s_image.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}

# ------------------------------------------------------------------------------
# 3. WORKER NODES (srv-k8s-02, srv-k8s-03: ARM64 1 OCPU, 8GB RAM each - Private Subnet)
# ------------------------------------------------------------------------------
resource "oci_core_instance" "srv_k8s_worker" {
  count               = var.worker_count
  availability_domain = local.k8s_ad
  compartment_id      = var.compartment_ocid
  display_name        = "srv-k8s-0${count.index + 2}"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.worker_ocpus
    memory_in_gbs = var.worker_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k8s_private_subnet.id
    assign_public_ip = false # 100% Private!
    display_name     = "vnic-srv-k8s-0${count.index + 2}"
    hostname_label   = "srv-k8s-0${count.index + 2}"
    private_ip       = "10.0.2.1${count.index + 2}"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.srv_k8s_image.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}
