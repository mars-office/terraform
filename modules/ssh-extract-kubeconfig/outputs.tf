output "kubeconfig" {
  value = replace(ssh_sensitive_resource.cat.result, "https://127.0.0.1:6443", "https://${var.ip}:6443")
  sensitive = true
}