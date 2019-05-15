terraform {
  required_version = ">= 0.11.1"
}

provider "random" {}

variable "location" {
  description = "Azure location in which to create resources"
  default     = "West US"
}

variable "name_prefix" {
  description = "Name prefix identifier to combine with random string for resource creation"
  default     = "tfe-demo"
}

variable "admin_password" {
  description = "admin password for Windows VM"
  default     = "pTFE1234!"
}

resource "random_string" "name_suffix" {
  length  = 4
  upper   = false
  lower   = true
  number  = false
  special = false
}

module "windowsserver" {
  source              = "Azure/compute/azurerm"
  version             = "1.1.5"
  location            = "${var.location}"
  resource_group_name = "${var.name_prefix}-${random_string.name_suffix.result}-rg"
  vm_hostname         = "${var.name_prefix}-${random_string.name_suffix.result}"
  admin_password      = "${var.admin_password}"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["${var.name_prefix}-${random_string.name_suffix.result}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "1.1.1"
  location            = "${var.location}"
  resource_group_name = "${var.name_prefix}-${random_string.name_suffix.result}-rg"
  allow_ssh_traffic   = true
}

output "windows_vm_public_name" {
  value = "${module.windowsserver.public_ip_dns_name}"
}
