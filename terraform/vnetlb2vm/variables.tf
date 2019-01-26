variable "subscription_id" {
  description = "enter your susbscription id"
}

variable ubuntuServer {
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

variable windowsServer {
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-smalldisk"
    version   = "latest"
  }
}

variable windows10 {
  default = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "RS3-Pro"
    version   = "latest"
  }
}

variable location {
  default = "northeurope"
}

variable prefix {
  default = "test"
}

# If we will check these in git, place these in an .env file instead
variable admin_username {
  default = "vmadmin"
}

variable admin_password {
  default = "Pa55w.rd1234"
}
