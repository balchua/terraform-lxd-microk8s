terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
    random = {
      source = "hashicorp/random"
      version = "~>3.1.0"
    }
  }
}