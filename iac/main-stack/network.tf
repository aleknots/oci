# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "k8s_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "k8s-vcn"
  dns_label      = "k8svcn"
}

# ------------------------------------------------------------------------------
# GATEWAYS
# ------------------------------------------------------------------------------

# Internet Gateway (para a Subnet Pública onde fica o Bastion)
resource "oci_core_internet_gateway" "k8s_ig" {
  compartment_id = var.compartment_ocid
  display_name   = "k8s-internet-gateway"
  vcn_id         = oci_core_vcn.k8s_vcn.id
  enabled        = true
}

# NAT Gateway (para a Subnet Privada onde ficam os nós do K8s)
resource "oci_core_nat_gateway" "k8s_nat_gw" {
  compartment_id = var.compartment_ocid
  display_name   = "k8s-nat-gateway"
  vcn_id         = oci_core_vcn.k8s_vcn.id
}

# ------------------------------------------------------------------------------
# ROUTE TABLES
# ------------------------------------------------------------------------------

# Tabela de Roteamento Pública (Bastion)
resource "oci_core_route_table" "k8s_public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "k8s-public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k8s_ig.id
  }
}

# Tabela de Roteamento Privada (Cluster K8s -> Tráfego de Saída via NAT Gateway)
resource "oci_core_route_table" "k8s_private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "k8s-private-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.k8s_nat_gw.id
  }
}

# ------------------------------------------------------------------------------
# SECURITY LISTS (FIREWALL)
# ------------------------------------------------------------------------------

# Firewall da Subnet Pública (Bastion)
resource "oci_core_security_list" "bastion_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "bastion-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Permitir SSH público apenas para o Bastion (Porta 22)
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "1" # ICMP Ping
    source    = "0.0.0.0/0"
    stateless = false
  }
}

# Firewall da Subnet Privada (Cluster K8s - 100% Isolado da Internet Direta)
resource "oci_core_security_list" "k8s_private_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "k8s-private-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Ingress Interno: Comunicação TOTAL entre todas as VMs na VCN (10.0.0.0/16)
  ingress_security_rules {
    protocol  = "all"
    source    = "10.0.0.0/16"
    stateless = false
  }
}

# ------------------------------------------------------------------------------
# SUBNETS
# ------------------------------------------------------------------------------

# Subnet Pública (Bastion Host)
resource "oci_core_subnet" "bastion_subnet" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.k8s_vcn.id
  display_name      = "bastion-public-subnet"
  dns_label         = "bastionsubnet"
  security_list_ids = [oci_core_security_list.bastion_sl.id]
  route_table_id    = oci_core_route_table.k8s_public_rt.id
}

# Subnet Privada (Cluster K8s Master e Workers)
resource "oci_core_subnet" "k8s_private_subnet" {
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.k8s_vcn.id
  display_name               = "k8s-private-subnet"
  dns_label                  = "k8sprivate"
  prohibit_public_ip_on_vnic = true # Garante que NENHUMA VM nesta subnet receba IP Público!
  security_list_ids          = [oci_core_security_list.k8s_private_sl.id]
  route_table_id             = oci_core_route_table.k8s_private_rt.id
}
