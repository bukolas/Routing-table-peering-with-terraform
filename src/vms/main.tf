resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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

resource "azurerm_public_ip" "pip-vm-vnetC" {
    name                = "pip-vm-vnetC"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Basic"
    allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "pip-vm-vnetB" {
    name                = "pip-vm-vnetB"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Basic"
    allocation_method = "Dynamic"
}

# Create Network Interfaces 
resource "azurerm_network_interface" "nic-vm-vnetC" {
    name                = "nic-vm-vnetC"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                      = azurerm_subnet.vnetC-subnet3.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip-vm-vnet3.id
    }
}

resource "azurerm_network_interface" "nic-vm-vnetB" {
    name                = "nic-vm-vnetB"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                      = azurerm_subnet.vnetB-subnet2.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip-vm-vnetB.id
    }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic-vm-vnetB" {
  network_interface_id      = azurerm_network_interface.nic-vm-vnetB.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "nsg-nic-vm-vnetC" {
  network_interface_id      = azurerm_network_interface.nic-vm-vnetC.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create Virtual Machine vnetC
resource "azurerm_virtual_machine" "vm-vnetC" {
    name                = "vm-vnetC"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    vm_size = "Standard_DS2_v2"
    network_interface_ids = [azurerm_network_interface.nic-vm-vnetC.id]

    os_profile {
        computer_name  = "myvm-vnetC"
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

# Create Virtual Machine vnetB
resource "azurerm_virtual_machine" "vm-vnetB" {
    name                = "vm-vnetB"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    vm_size = "Standard_DS2_v2"
    network_interface_ids = [azurerm_network_interface.nic-vm-vnetB.id]

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