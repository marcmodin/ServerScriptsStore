variable name {
  description = "Name of the virtual network"
}

variable resource_group_name {
  description = "Resource group name"
}

variable resource_group_location {
  description = "Geographic location of the Resource Group"
}

variable address_space {
  description = "Default virtual network address space"
}

resource "azurerm_virtual_network" "net" {
  name          = "${var.name}"
  address_space = ["${var.address_space}"]

  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
}

output "name" {
  value = "${azurerm_virtual_network.net.name}"
}

output "id" {
  value = "${azurerm_virtual_network.net.id}"
}
