resource "azurerm_resource_group" "network" {
    name = "development"
    location = "North Europe"
}

resource "azurerm_virtual_network" "network" {
    name = "development-network"
    address_space = ["10.0.0.0/16"]
    location = "${azurerm_resource_group.network.location}"
    resource_group_name = "${azurerm_resource_group.network.name}"

    subnet {
        name = "${azurerm_resource_group.network.name}-frontend"
        address_prefix = "10.0.1.0/24"
        security_group = "${azurerm_network_security_group.network.id}"
    }

    subnet {
        name = "${azurerm_resource_group.network.name}-backend"
        address_prefix = "10.0.2.0/24"
    }
}



resource "azurerm_network_security_group" "network" {
  name                = "allowIncomingHttp"
  location            = "${azurerm_resource_group.network.location}"
  resource_group_name = "${azurerm_resource_group.network.name}"

    security_rule {
        name = "allow-internet-port-80"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "*"
        source_address_prefix       = "*"
        source_port_range           = "*"
        destination_address_prefix  = "*"
        destination_port_range = "80"
    }
}
