output "vms" {
  value = {for v in var.vms : v.name => {
    master = v.master
    primary = v.primary
    public_ip = v.primary == true ? oci_core_instance.vm_primary[v.name].public_ip : oci_core_instance.vm[v.name].public_ip
  }}
}