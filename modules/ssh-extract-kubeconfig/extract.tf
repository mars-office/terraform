resource "ssh_sensitive_resource" "cat" {
  when = "create"
  host         = var.ip
  user         = "ubuntu"
  private_key = var.sshKeyPrivate
  retry_delay = "2s"
  timeout = "15m"
  pre_commands = [
    "sleep 60"
  ]
  commands = [
    "sudo cat /etc/rancher/k3s/k3s.yaml"
  ]
}

