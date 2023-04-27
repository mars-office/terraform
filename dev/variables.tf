variable "env" {
  type = string
  default = "dev"
}

variable "testSecret" {
  type = string
  sensitive = true
}
