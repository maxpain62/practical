resource "azurerm_network_security_group" "tf-demo-nsg" {
  name                = "tf-demo-nsg"
  location            = azurerm_resource_group.tf-demo-rg.location
  resource_group_name = azurerm_resource_group.tf-demo-rg.name
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    env = "dev"
  }
}

resource "azurerm_virtual_network" "tf-demo-vnet" {
  name                = "tf-demo-vnet"
  location            = azurerm_resource_group.tf-demo-rg.location
  resource_group_name = azurerm_resource_group.tf-demo-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    env = "dev"
  }
}

resource "azurerm_subnet" "tf-demo-subnet1" {
  name                 = "tf-demo-subnet1"
  resource_group_name  = azurerm_resource_group.tf-demo-rg.name
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.tf-demo-vnet.name

  tags = {
    env = "dev"
  }
}