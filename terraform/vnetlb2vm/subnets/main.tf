variable name {
  type        = "list"
  default     = ["default"]
  description = "Name of the virtual network: expects list from module call"
}

variable resource_group_name {
  description = "Resource group name"
}

variable virtual_network_name {
  description = "Virtual network name"
}

variable address_prefix {
  type        = "list"
  description = "List of subnets to create"
}

# Create and attach Subnet
resource "azurerm_subnet" "net" {
  count                = "${length(var.address_prefix)}"
  name                 = "${element(var.name,count.index)}"           # expects list from module
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${element(var.address_prefix,count.index)}"

  // network_security_group_id = "${azurerm_network_security_group.http.id}"
}

output "name" {
  value = "${list(azurerm_subnet.net.*.name)}"
}

output "id" {
  value = "${list(azurerm_subnet.net.*.id)}"
}

output "subnets" {
  value = "${list(azurerm_subnet.net.*.address_prefix)}"
}

output "subnet_ids" {
  value = "${zipmap(azurerm_subnet.net.*.name, azurerm_subnet.net.*.id)}"
}
