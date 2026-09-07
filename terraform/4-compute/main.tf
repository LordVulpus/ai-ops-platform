resource "azurerm_resource_group" "rg" {
  name     = "az-mothershipwest"
  location = var.location
}

resource "azurerm_public_ip" "pip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "${var.prefix}PublicIP"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}VMNic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfigaz-centralcomputer"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
    subnet_id                     = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/virtualNetworks/az-centralcomputerVNET/subnets/az-centralcomputerSubnet"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/networkSecurityGroups/az-centralcomputerNSG"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.prefix
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B2ats_v2"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]
  secure_boot_enabled   = true
  vtpm_enabled          = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key # Clean variable integration!
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
