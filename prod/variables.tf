variable "env" {
  type = string
  default = "prod"
}

variable "testSecret" {
  type = string
  sensitive = true
}
