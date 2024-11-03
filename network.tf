resource "azurerm_virtual_network" "tp2_vn" {
  name                = "tp2_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tp2_resource_group.location
  resource_group_name = azurerm_resource_group.tp2_resource_group.name
}

resource "azurerm_subnet" "tp2_sn_vmss" {
  name                 = "tp2_vmss_subnet"
  resource_group_name  = azurerm_resource_group.tp2_resource_group.name
  virtual_network_name = azurerm_virtual_network.tp2_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "tp2_sn_jumpbox" {
  name                 = "tp2_jumpbox_subnet"
  resource_group_name  = azurerm_resource_group.tp2_resource_group.name
  virtual_network_name = azurerm_virtual_network.tp2_vn.name
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_subnet" "tp2_sn_container" {
  name                 = "tp2_container_subnet"
  resource_group_name  = azurerm_resource_group.tp2_resource_group.name
  virtual_network_name = azurerm_virtual_network.tp2_vn.name
  address_prefixes     = ["10.0.4.0/24"]

  delegation {
    name = "tp2_sn_container_delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}
