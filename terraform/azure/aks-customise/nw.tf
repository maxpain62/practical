resource "azurerm_virtual_network" "tfByoVnet" {
  resource_group_name = azurerm_resource_group.tfByoRG.name
  location = azurerm_resource_group.tfByoRG.location
  name = "tfByoVnet"
  address_space = ["192.168.0.0/16"]
  subnet {
    name = "tfByoSubnet1"
    address_prefixes =  ["192.168.0.0/22"]
  }
}