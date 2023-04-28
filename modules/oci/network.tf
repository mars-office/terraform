# Network and subnet

resource "oci_core_vcn" "vcn" {
  cidr_block     = local.vcn_subnet
  compartment_id = var.ociCompartmentOcid
  display_name   = "${var.env}_marsoffice_vcn"
  dns_label      = "marsoffice${var.env}"
  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
}

resource "oci_core_default_security_list" "security_list" {
  compartment_id             = var.ociCompartmentOcid
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
  display_name               = "${var.env}_marsoffice_security_list"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol    = 6 # tcp
    source      = "0.0.0.0/0"
    description = "Allow SSH"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol    = "all"
    source      = local.vcn_subnet
    description = "Allow all from vcn subnet"
  }

  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
}

resource "oci_core_subnet" "k3s_subnet" {
  cidr_block        = local.k3s_subnet
  compartment_id    = var.ociCompartmentOcid
  display_name      = "${var.env}_k3s_subnet"
  dns_label         = "k3s"
  route_table_id    = oci_core_vcn.vcn.default_route_table_id
  vcn_id            = oci_core_vcn.vcn.id
  security_list_ids = [oci_core_default_security_list.security_list.id]
  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
}


resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.ociCompartmentOcid
  display_name   = "${var.env}_marsoffice_internet_gateway"
  enabled        = "true"
  vcn_id         = oci_core_vcn.vcn.id
  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
}

resource "oci_core_default_route_table" "default_oci_core_default_route_table" {
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
}


# NSG
resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.ociCompartmentOcid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.env}_marsoffice_k3s_nsg"

  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
}

resource "oci_core_network_security_group_security_rule" "allow_http_from_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow HTTP from all"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_https_from_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow HTTPS from all"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_kubeapi_from_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow KubeAPI from all"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}
