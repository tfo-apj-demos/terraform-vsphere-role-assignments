terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.6.1"
    }
  }
  cloud {
    organization = "tfo-apj-demos"
    workspaces {
      name = "vsphere-role-assignments"
    }
  }
}