terraform {
  required_providers {
    tfcoremock = {
      source = "hashicorp/tfcoremock"
      version = "0.1.2"
    }
  }
}

provider "tfcoremock" {
  # Configuration options
}

module "module1" {
  source = "./module1"
}

module "module2" {
  source = "./module2"
  # depends_on = [
  #   module.module1
  # ]
}


