terraform {
  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}
