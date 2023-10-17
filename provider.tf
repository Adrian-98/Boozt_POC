terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "POC_sentinel_boozt"
    workspaces {
      name = "Boozt_POC"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.44"
    }
  }
}
