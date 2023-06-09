resource "random_password" "k3s_token" {
  length  = 55
  special = false
}


data "cloudinit_config" "init_vm" {
  for_each = {
    for index, vm in var.vms : vm.name => vm if vm.primary == false
  }
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/init_vm.sh", {
      k3s_token = random_password.k3s_token.result
      k3s_url = "https://${oci_core_instance.vm_primary[local.primaryMasterName].private_ip }:6443"
      master = "${each.value.master}"
      primary = "${each.value.primary}"
      cluster_dns = ""
    })
  }
}

data "cloudinit_config" "init_vm_primary" {
  for_each = {
    for index, vm in var.vms : vm.name => vm if vm.primary == true && vm.master == true
  }
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/init_vm.sh", {
      k3s_token = random_password.k3s_token.result
      k3s_url = ""
      master = "${each.value.master}"
      primary = "${each.value.primary}"
      cluster_dns = var.clusterDns
    })
  }
}
