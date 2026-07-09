resource "azurerm_network_interface" "res-0" {
  location            = "ukwest"
  name                = "az-centralcomputerVMNic"
  resource_group_name = "az-mothershipwest"
  ip_configuration {
    name                          = "ipconfigaz-centralcomputer"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/publicIPAddresses/az-centralcomputerPublicIP"
    subnet_id                     = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/virtualNetworks/az-centralcomputerVNET/subnets/az-centralcomputerSubnet"
  }
}
resource "azurerm_network_interface_security_group_association" "res-1" {
  network_interface_id      = azurerm_network_interface.res-0.id
  network_security_group_id = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/networkSecurityGroups/az-centralcomputerNSG"
}
resource "azurerm_linux_virtual_machine" "res-0" {
  admin_username        = "azureuser"
  location              = "ukwest"
  name                  = "az-centralcomputer"
  network_interface_ids = ["/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/networkInterfaces/az-centralcomputerVMNic"]
  resource_group_name   = "az-mothershipwest"
  secure_boot_enabled   = true
  size                  = "Standard_B2ats_v2"
  vtpm_enabled          = true
  admin_ssh_key {
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbHcSC3HMfhrvL6U72J35dMzdbzwUPeL5hh2LoIVTVfTgSFydE6qou823JN70OxFc9MTcd4Sno6tevMwJwTSL3vat1omR5/Qf2hUe44kwxucH3QY65ucPg7Ib0MpJekLa2bo4PWVT2RkwKG0mp1S55MTqvnQ+xGjURLzzxU+WuhaNK+aV9DRVo4hLROHNRKEKv77nqUHmDMXbyrL1B4GF26Li0hCV8Kz/Iqw4o7kNGleCrDhUpelUk9IdcZsBGyX6+3SalBZPbrbllriFGOJG722rEKqU3wAufWhxalfwi3VVF3bZaiAzRPf9/7ha8nPezaGrMCr/BPXcEXPJqa2Nf"
    username   = "azureuser"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
