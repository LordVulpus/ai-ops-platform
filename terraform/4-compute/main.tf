# terraform/4-compute/main.tf

# 1. Core resource group declaration matching state
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Reconstructed Jumpbox VM matching your true live specifications
resource "azurerm_linux_virtual_machine" "vm" {
  name                                 = var.jumpbox_vm_name
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  size                                 = "Standard_B2ats_v2"
  admin_username                       = "azureuser"
  secure_boot_enabled                  = true
  vtpm_enabled                         = true
  encryption_at_host_enabled           = false
  vm_agent_platform_updates_enabled    = true # Locked to true to match live environment

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    name                 = "${var.jumpbox_vm_name}_OsDisk_1_6d65595788b44266b5e9687c4880ebd4"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Prevent automated SSH key mismatches from tearing down the VM
  lifecycle {
    ignore_changes = [admin_ssh_key]
  }
}

# 3. Corrected Network Interface referencing your exact live subnet names
resource "azurerm_network_interface" "nic" {
  name                = "${var.jumpbox_vm_name}VMNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfigaz-centralcomputer"
    subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/az-centralcomputerVNET/subnets/az-centralcomputerSubnet"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# 4. Restored Network Security Group association to prevent network disconnects
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/networkSecurityGroups/az-centralcomputerNSG"
}

# 5. Map your live Jumpbox Public IP asset
resource "azurerm_public_ip" "pip" {
  name                = "${var.jumpbox_vm_name}PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
