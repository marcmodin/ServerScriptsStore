variable name {
  default     = "default"
  description = "Name of the availabilityset"
}

variable resource_group_name {
  description = "Resource group name"
}

variable resource_group_location {
  description = "Geographic location of the Resource Group"
}

resource "azurerm_availability_set" "set" {
  name                         = "${var.name}"
  location                     = "${var.resource_group_location}"
  resource_group_name          = "${var.resource_group_name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

output "name" {
  value = "${azurerm_availability_set.set.name}"
}

output "id" {
  value = "${azurerm_availability_set.set.id}"
}
