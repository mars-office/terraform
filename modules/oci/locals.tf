locals {
  vcn_subnet = "10.0.0.0/16"
  k3s_subnet = "10.0.0.0/24"
  primaryMasterName = length(var.vms) > 0 ? [for v in var.vms : v.name if v.master == true && v.primary == true][0] : null
}
