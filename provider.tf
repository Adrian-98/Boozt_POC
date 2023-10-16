terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Devoteam-G-Cloud"
    workspaces {
      name = "Enonic_POC"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.44"
    }
  }
}
