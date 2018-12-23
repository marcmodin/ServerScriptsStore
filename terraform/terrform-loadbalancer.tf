
resource "azurerm_resource_group" "network" {
    name = "LoadBalancer_RG"
    location = "North Europe"
}

resource "azurerm_availability_set" "network" {
    name = "${azurerm_lb.network.name}_ASet"
    location = "${azurerm_resource_group.network.location}"
    resource_group_name = "${azurerm_resource_group.network.name}"
    platform_fault_domain_count = "2"
}

resource "azurerm_virtual_network" "network" {
    name = "${azurerm_lb.network.name}_VNet"
    address_space = ["10.0.0.0/24"]
    location = "${azurerm_resource_group.network.location}"
    resource_group_name = "${azurerm_resource_group.network.name}"

    subnet {
        name = "${azurerm_lb.network.name}-frontend"
        address_prefix = "10.0.1.0/24"
    }
}

resource "azurerm_public_ip" "network" {
    name = "LB_IP"
    location = "${azurerm_resource_group.network.location}"
    resource_group_name = "${azurerm_resource_group.network.name}"
    public_ip_address_allocation = "dynamic"
}

resource "azurerm_lb" "network" {
    name = "LB"
    location = "${azurerm_resource_group.network.location}"
    resource_group_name = "${azurerm_resource_group.network.name}"

    frontend_ip_configuration {
      name = "LB_PublicIP"
      public_ip_address_id = "${azurerm_public_ip.network.id}"
    }
}

resource "azurerm_lb_backend_address_pool" "network"{
  name = "${azurerm_lb.network.name}_BackendAPool"
  loadbalancer_id = "${azurerm_lb.network.id}"
  resource_group_name = "${azurerm_resource_group.network.name}"
}

resource  "azurerm_lb_rule" "network"{
  name = "${azurerm_lb.network.name}_Rule"
  loadbalancer_id = "${azurerm_lb.network.id}"
  resource_group_name = "${azurerm_resource_group.network.name}"
  protocol = "tcp"
  backend_port = "80"
  frontend_port = "80"
  frontend_ip_configuration_name = "${azurerm_lb.network.frontend_ip_configuration.name}"
}

resource "azurerm_lb_probe" "network" {
  name = "${azurerm_lb.network.name}_Probe"
  loadbalancer_id = "${azurerm_lb.network.id}"
  resource_group_name = "${azurerm_resource_group.network.name}"
  protocol            = "tcp"
  port                = 80
}
