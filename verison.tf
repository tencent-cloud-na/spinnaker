terraform {
  required_version = "> 0.14.06"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}
