variable "backend_rg_name" {
  type    = string
  default = "rg-terraform-tfstate"
}

variable "backend_storage_name" {
  type    = string
  default = "sttfstatebootstrap01"
}

variable "backend_container_name" {
  type    = string
  default = "tfstate"
}

variable "location" {
  type    = string
  default = "eastus"
}
