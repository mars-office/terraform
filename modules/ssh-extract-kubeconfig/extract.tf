resource "ssh_sensitive_resource" "cat" {
  when = "create"
  host         = var.ip
  user         = "ubuntu"
  private_key = var.sshKeyPrivate
  retry_delay = "30s"
  timeout = "15m"
  commands = [
    "sudo cat /etc/rancher/k3s/k3s.yaml"
  ]

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

