resource "ssh_sensitive_resource" "cat" {
  when = "create"
  host         = var.ip
  user         = "ubuntu"
  private_key = var.sshKeyPrivate
  timeout = "30s"
  commands = [
    "sudo cat /etc/rancher/k3s/k3s.yaml"
  ]
}

