variable name {
  default     = "default"
  description = "Name of the resource group"
}

variable location {
  default     = "Central US"
  description = "Geographic location of the Resource Group"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}"
  location = "${var.location}"
}

output "name" {
  value = "${azurerm_resource_group.rg.name}"
}

output "id" {
  value = "${azurerm_resource_group.rg.id}"
}

output "location" {
  value = "${azurerm_resource_group.rg.location}"
}
