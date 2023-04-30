variable "sshKeyPrivate" {
  type = string
  sensitive = true
}

variable "ip" {
  type = string
}

variable "clusterDns" {
  type = string
}