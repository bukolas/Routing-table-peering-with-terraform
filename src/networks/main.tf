resource azurerm_resource_group "rg" {
    name = "resource_rg"
    location = "Sweden Central"
}


resource azurerm_virtual_network "vnetA" {
    name = "peerA-vnet"
    location = azurerm_resource_group.rg.location
    address_space = ["10.0.0.0/16"]
    resource_group_name = azurerm_resource_group.rg.name

}

resource "azurerm_subnet" "sbnA" {
    name = "peerA-sbn"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnetA.name
    address_prefixes = ["10.0.0.0/24"]
  
}

resource azurerm_virtual_network "vnetB" {
    name = "peerB-vnet"
    location = azurerm_resource_group.rg.location
    address_space = ["10.1.0.0/16"]
    resource_group_name = azurerm_resource_group.rg.name

}

resource "azurerm_subnet" "sbnB" {
    name = "peerB-sbn"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnetB.name
    address_prefixes = ["10.1.0.0/24"]
  
}

resource azurerm_virtual_network "vnetC" {
    name = "peerC-vnet"
    location = azurerm_resource_group.rg.location
    address_space = ["10.2.0.0/16"]
    resource_group_name = azurerm_resource_group.rg.name

}

resource "azurerm_subnet" "sbnC" {
    name = "peerC-sbn"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnetC.name
    address_prefixes = ["10.2.0.0/24"]
  
}

resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                         = "vnet1-to-vnet2"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnetA.name
  remote_virtual_network_id    = azurerm_virtual_network.vnetB.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "vnet1_to_vnet3" {
  name                         = "vnet1-to-vnet3"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnetA.name
  remote_virtual_network_id    = azurerm_virtual_network.vnetC.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_public_ip" "gateway_ip" {
    name                = "gateway-ip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vnet_gateway" {
    name                = "vnet_gateway"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.sbnA.id
    }
}


resource "azurerm_route_table" "vnet2-rt" {
  name                = "vnet2-rt"
  location            = azurerm_resource_group.rg_peering.location
  resource_group_name = azurerm_resource_group.rg_peering.name
}

resource "azurerm_route" "vnet2-to-vnet3" {
  name                = "vnet2-to-vnet3"
  resource_group_name = azurerm_resource_group.rg_peering.name
  route_table_name    = azurerm_route_table.vnet2-rt.name
  address_prefix      = azurerm_virtual_network.vnet3.address_space[0]
  next_hop_type       = "VirtualNetworkGateway"
}

resource "azurerm_route" "vnet3-to-vnet2" {
  name                = "vnet3-to-vnet2"
  resource_group_name = azurerm_resource_group.rg_peering.name
  route_table_name    = azurerm_route_table.vnet2-rt.name
  address_prefix      = azurerm_virtual_network.vnet2.address_space[0]
  next_hop_type       = "VirtualNetworkGateway"
}

resource "azurerm_subnet_route_table_association" "vnet2-rt-association" {
  subnet_id      = azurerm_subnet.vnet2-subnet2.id
  route_table_id = azurerm_route_table.vnet2-rt.id
}


resource "azurerm_subnet_route_table_association" "vnet3-rt-association" {
  subnet_id      = azurerm_subnet.vnet3-subnet3.id
  route_table_id = azurerm_route_table.vnet2-rt.id
}