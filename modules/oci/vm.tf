resource "oci_core_instance" "vm" {
  for_each = {
    for index, vm in var.vms : vm.name => vm if vm.primary == false
  }
  availability_domain = each.value.availabilityDomain
  compartment_id      = var.ociCompartmentOcid
  shape               = each.value.shape
  agent_config {
    is_management_disabled = false
    is_monitoring_disabled = false
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = true
    display_name              = "vnic-marsoffice-${each.key}-${var.env}"
    freeform_tags = {
      "provisioner" = "terraform"
      "env"         = var.env
    }
    hostname_label = "${each.key}${var.env}"
    nsg_ids        = [oci_core_network_security_group.nsg.id]
    subnet_id      = oci_core_subnet.k3s_subnet.id
  }
  display_name = "vm-marsoffice-${each.key}-${var.env}"
  fault_domain = each.value.faultDomain
  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
  is_pv_encryption_in_transit_enabled = false
  metadata = {
    "ssh_authorized_keys" = var.sshKeyPublic
    "user_data"           = data.cloudinit_config.init_vm[each.key].rendered
  }
  shape_config {
    memory_in_gbs = each.value.ram
    ocpus         = each.value.cpus
  }
  source_details {
    source_id               = each.value.osImageId
    source_type             = "image"
    boot_volume_size_in_gbs = "${each.value.ssdSize}"
  }
  preserve_boot_volume = false
}


resource "oci_core_instance" "vm_primary" {
  for_each = {
    for index, vm in var.vms : vm.name => vm if vm.primary == true && vm.master == true
  }
  availability_domain = each.value.availabilityDomain
  compartment_id      = var.ociCompartmentOcid
  shape               = each.value.shape
  agent_config {
    is_management_disabled = false
    is_monitoring_disabled = false
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = true
    display_name              = "vnic-marsoffice-${each.key}-${var.env}"
    freeform_tags = {
      "provisioner" = "terraform"
      "env"         = var.env
    }
    hostname_label = "${each.key}"
    nsg_ids        = [oci_core_network_security_group.nsg.id]
    subnet_id      = oci_core_subnet.k3s_subnet.id
  }
  display_name = "vm-marsoffice-${each.key}-${var.env}"
  fault_domain = each.value.faultDomain
  freeform_tags = {
    "provisioner" = "terraform"
    "env"         = var.env
  }
  is_pv_encryption_in_transit_enabled = false
  metadata = {
    "ssh_authorized_keys" = var.sshKeyPublic
    "user_data"           = data.cloudinit_config.init_vm_primary[each.key].rendered
  }
  shape_config {
    memory_in_gbs = each.value.ram
    ocpus         = each.value.cpus
  }
  source_details {
    source_id               = each.value.osImageId
    source_type             = "image"
    boot_volume_size_in_gbs = "${each.value.ssdSize}"
  }
  preserve_boot_volume = false
}
