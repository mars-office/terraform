variable "env" {
  type = string
  default = "uat"
}

variable "testSecret" {
  type = string
  sensitive = true
}
