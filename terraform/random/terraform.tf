## resources https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.20.0"
  subscription_id = "[SUBSCRIPTION_ID]"
}

# Variables
variable "prefix" {
  default = "test"
}
variable "location" {
  default = "North Europe"
}

variable "vm_size" {
  default = "Standard_DS1_v2"
}

# Count Variable, Usage : count  = "${var.num_vms}"
variable "vm_count" {
  default = "1"
}

# Count Variables
count  = "${var.num_vms}"

locals {
  resource_prefix = "${var.prefix}"
  resource_location = "${var.location}"
  virtual_machine_name = "${var.prefix}-client"
  virtual_machine_size = "${var.vm_size}"
  virtual_machine_count = "${var.num_vms}"
  managed_disk_type = "Standard_LRS"
  admin_username = "marcmodin"
  admin_password = "Pa55w.rd1234"
}

# Configure the Azure Provider
provider "azurerm" {
  version = "=1.20.0"
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "${local.resource_prefix}-resources"
  location = "${local.resource_location}"
}

# Create Virtual Network
resource "azurerm_virtual_network" "test" {
  name                = "${local.resource_prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

# Create and attach Subnet
resource "azurerm_subnet" "default" {
  name                 = "frontend"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_security_group" "test" {
  name                = "${azurerm_subnet.test.name}-rules"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  security_rule {
    name                       = "80Allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_public_ip" "vmpip" {
  name                         = "ip${count.index}"
  location                     = "${azurerm_resource_group.test.location}"
  resource_group_name          = "${azurerm_resource_group.test.name}""
  public_ip_address_allocation = "dynamic"
  count                        = "${local.virtual_machine_count}"
}

resource "azurerm_network_interface" "vmnic" {
  name                = "${count.index}nic"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  count               = "${local.virtual_machine_count}"

  ip_configuration {
    name                          = "${count.index}configuration"
    subnet_id                     = "${azurerm_subnet.default.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.vmpip.*.id, count.index)}"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "${local.virtual_machine_name}"
  location              = "${azurerm_resource_group.test.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${element(azurerm_network_interface.vmnic.*.id, count.index)}"]
  vm_size               = "${local.virtual_machine_size}"
  count                 = "${local.virtual_machine_count}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${local.managed_disk_type}"
  }
  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${local.admin_username}"
    admin_password = "${local.admin_password}"
  }
  os_profile_windows_config {
  provision_vm_agent        = true
  enable_automatic_upgrades = true
  }
}
