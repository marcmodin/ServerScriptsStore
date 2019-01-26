# Configure the Azure Provider
provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version         = "1.21.0"
  subscription_id = "${var.subscription_id}"
}

module "resource_group" {
  source   = "./resourcegroup"
  name     = "${var.prefix}"
  location = "northeurope"
}

module "vnets" {
  source                  = "./vnets"
  name                    = "${var.prefix}-vnet"
  resource_group_name     = "${module.resource_group.name}"
  resource_group_location = "${module.resource_group.location}"
  address_space           = "10.0.0.0/16"
}

module "subnets" {
  source = "./subnets"

  resource_group_name  = "${module.resource_group.name}"
  virtual_network_name = "${module.vnets.name}"

  name           = ["frontend", "backend"]
  address_prefix = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "availabilty_set_server" {
  source = "./availabilityset"

  name                    = "${var.prefix}-avset-server"
  resource_group_name     = "${module.resource_group.name}"
  resource_group_location = "${module.resource_group.location}"
}

# module "availabilty_set_client" {
#   source                  = "./availabilityset"
#   name                    = "${var.prefix}-avset-client"
#   resource_group_name     = "${module.resource_group.name}"
#   resource_group_location = "${module.resource_group.location}"
# }

module "loadbalancer_frontend" {
  source = "./lbs"

  # count                   = "${module.vm_server.vm_count}"
  name                    = "${var.prefix}-loadbalancer"
  resource_group_name     = "${module.resource_group.name}"
  resource_group_location = "${module.resource_group.location}"

  # nic_backendpool_id      = "${module.vm_server.networkinterface_id}"
  # nic_configuration_name  = "${module.vm_server.ip_configuration_name}"
}

module "vm_server" {
  source = "./vms"

  resource_group_name     = "${module.resource_group.name}"
  resource_group_location = "${module.resource_group.location}"

  subnet_id                       = "${lookup(module.subnets.subnet_ids, "backend")}"
  availability_set                = "${module.availabilty_set_server.id}"
  azurerm_lb_backend_address_pool = "${module.loadbalancer_frontend.backend_address_pool_id}"
  count                           = "2"
  hostname                        = "server"
  vm_size                         = "Standard_B1s"
  os_image_source                 = "${var.ubuntuServer}"

  admin_username = "${var.admin_username}"
  admin_password = "${var.admin_password}"
}

# module "vm_client" {
#   source = "./vms"


#   resource_group_name     = "${module.resource_group.name}"
#   resource_group_location = "${module.resource_group.location}"


#   subnet_id        = "${lookup(module.subnets.subnet_ids, "frontend")}"
#   availability_set = "${module.availabilty_set_client.id}"


#   count           = "1"
#   hostname        = "client"
#   vm_size         = "Standard_B1s"
#   os_image_source = "${var.windowsServer}"


#   admin_username = "${var.admin_username}"
#   admin_password = "${var.admin_password}"
# }


# Declaring globally unique random id generator
# resource "random_integer" "int" {
#   min = 100
#   max = 999


#   # dns_name            = "default${random_integer.int.result}"
# }

