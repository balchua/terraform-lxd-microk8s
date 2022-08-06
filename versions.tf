terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
      version = "~>1.6.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~>3.1.0"
    }
  }
}