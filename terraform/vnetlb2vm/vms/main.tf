variable resource_group_name {
  description = "Resource group name"
}

variable resource_group_location {
  description = "Geographic location of the Resource Group"
}

variable subnet_id {
  description = "Describe which subnet id to use maps to subnetsmodule"
}

variable count {
  default = "1"
}

variable vm_size {
  description = "Size of the VM."
}

variable "hostname" {
  description = "VM name referenced also in storage-related names."
}

variable "os_image_source" {
  type        = "map"
  description = "VM OS Image. Found in globalvars"
}

variable "availability_set" {
  description = "Describe id to availability set"
}

variable "azurerm_lb_backend_address_pool" {
  description = "Describe id to loadbalancer backend addresspool"
}

variable admin_username {
  description = "IMPORTANT! admin_username: do not hard code these vars here"
}

variable admin_password {
  description = "IMPORTANT! admin_password: do not hard code these vars here"
}

resource "azurerm_public_ip" "pip" {
  count               = "${var.count}"
  name                = "${count.index}-ip"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count               = "${var.count}"
  name                = "${format("%v-%vVM", var.hostname, count.index)}-nic"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"

  ip_configuration {
    name                          = "${var.resource_group_name}-ipconfig"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.pip.*.id, count.index)}"

    # load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.tcp.*.id, count.index)}"]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "test" {
  count                   = "${var.count}"
  network_interface_id    = "${element(azurerm_network_interface.nic.*.id,count.index)}"
  ip_configuration_name   = "${var.resource_group_name}-ipconfig"
  backend_address_pool_id = "${var.azurerm_lb_backend_address_pool}"
}

resource "azurerm_virtual_machine" "vm" {
  count   = "${var.count}"
  name    = "${format("%v-%vVM", var.hostname, count.index)}"
  vm_size = "${var.vm_size}"

  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"

  network_interface_ids            = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  primary_network_interface_id     = "${format("%v", element(azurerm_network_interface.nic.*.id, count.index))}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  availability_set_id     = "${var.availability_set}"
  storage_image_reference = "${list(var.os_image_source)}"
  depends_on              = ["azurerm_network_interface.nic"]

  storage_os_disk {
    name              = "${format("%v-osdisk%vVM", var.hostname, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = 30
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${format("%v-%vVM", var.hostname, count.index)}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    # provision_vm_agent        = true #on Windows
    # enable_automatic_upgrades       = true #on windows
    disable_password_authentication = false
  }
}

output "name" {
  value = "${list(azurerm_virtual_machine.vm.*.name)}"
}

output "id" {
  value = "${list(azurerm_virtual_machine.vm.*.id)}"
}

output "vm_count" {
  value = "${var.count}"
}

output "networkinterface_id" {
  value = "${list(azurerm_network_interface.nic.*.id)}"
}

output "ip_configuration_name" {
  value = "${var.resource_group_name}-ipconfig}"
}
