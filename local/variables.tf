variable "env" {
  type = string
  default = "local"
}

variable "testSecret" {
  type = string
  sensitive = true
}
