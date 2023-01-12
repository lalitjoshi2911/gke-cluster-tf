terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.48.0"
    }
  }
}

provider "google" {
  project     = var.project-name
  region      = var.region-name
  zone        = var.zone-name
  credentials = "./key/tf-account.json"
}
