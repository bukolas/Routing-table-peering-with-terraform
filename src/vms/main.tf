resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg_peering.location
  resource_group_name = azurerm_resource_group.rg_peering.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pip-vm-vnet3" {
    name                = "pip-vm-vnet3"
    location            = azurerm_resource_group.rg_peering.location
    resource_group_name = azurerm_resource_group.rg_peering.name
    sku = "Basic"
    allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "pip-vm-vnet2" {
    name                = "pip-vm-vnet2"
    location            = azurerm_resource_group.rg_peering.location
    resource_group_name = azurerm_resource_group.rg_peering.name
    sku = "Basic"
    allocation_method = "Dynamic"
}

# Create Network Interfaces 
resource "azurerm_network_interface" "nic-vm-vnet3" {
    name                = "nic-vm-vnet3"
    location            = azurerm_resource_group.rg_peering.location
    resource_group_name = azurerm_resource_group.rg_peering.name
    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                      = azurerm_subnet.vnet3-subnet3.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip-vm-vnet3.id
    }
}

resource "azurerm_network_interface" "nic-vm-vnet2" {
    name                = "nic-vm-vnet2"
    location            = azurerm_resource_group.rg_peering.location
    resource_group_name = azurerm_resource_group.rg_peering.name
    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                      = azurerm_subnet.vnet2-subnet2.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip-vm-vnet2.id
    }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic-vm-vnet2" {
  network_interface_id      = azurerm_network_interface.nic-vm-vnet2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "nsg-nic-vm-vnet3" {
  network_interface_id      = azurerm_network_interface.nic-vm-vnet3.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create Virtual Machine vnet3
resource "azurerm_virtual_machine" "vm-vnet3" {
    name                = "vm-vnet3"
    location            = azurerm_resource_group.rg_peering.location
    resource_group_name = azurerm_resource_group.rg_peering.name
    vm_size = "Standard_DS2_v2"
    network_interface_ids = [azurerm_network_interface.nic-vm-vnet3.id]

    os_profile {
        computer_name  = "myvm-vnet3"
        admin_username = "adminuser"
        admin_password = "Password1234!"

        custom_data = base64encode("cloud-init script or custom data for VM")
    }

    storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}

# Create Virtual Machine vnet2
resource "azurerm_virtual_machine" "vm-vnet2" {
    name                = "vm-vnet2"
    location            = azurerm_resource_group.rg_peering.location
    resource_group_name = azurerm_resource_group.rg_peering.name
    vm_size = "Standard_DS2_v2"
    network_interface_ids = [azurerm_network_interface.nic-vm-vnet2.id]

    os_profile {
        computer_name  = "myvm-vnet2"
        admin_username = "adminuser"
        admin_password = "Password1234!"

        custom_data = base64encode("cloud-init script or custom data for VM")
    }

    storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}