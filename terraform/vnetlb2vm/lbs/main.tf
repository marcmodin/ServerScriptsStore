variable name {
  description = "Name of the availabilityset"
}

variable resource_group_name {
  description = "Resource group name"
}

variable resource_group_location {
  description = "Geographic location of the Resource Group"
}

# variable nic_backendpool_id {
#   default     = ""
#   description = "Network interface id"
# }

# variable nic_configuration_name {
#   description = "Network interface ip configuration name"
# }

variable count {
  default     = 1
  description = ""
}

resource "azurerm_public_ip" "lb" {
  # count               = "${var.count}"
  name                = "${count.index}-lb-ip"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${var.resource_group_name}"
  name                = "${var.name}lb"
  location            = "${var.resource_group_location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "RDP-VM-${count.index}"
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
  depends_on          = ["azurerm_lb.lb"]
}

output "id" {
  value = "${azurerm_lb.lb.id}"
}

output "backend_address_pool_id" {
  value = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}

# output "load_balancer_inbound_nat_rules_ids" {
#   value = "${list(azurerm_lb_nat_rule.tcp.*.id)}"
# }

