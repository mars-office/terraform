variable "cloudflareToken" {
  type = string
  sensitive = true
}

variable "zoneName" {
  type = string
}

variable "records" {
  type = list(object({
    name = string
    type = string
    value = string
  }))
}