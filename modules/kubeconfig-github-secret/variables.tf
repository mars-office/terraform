variable "kubeconfig" {
  type = string
  sensitive = true
}

variable "ghToken" {
  type = string
  sensitive = true
}

variable "env" {
  type = string
}