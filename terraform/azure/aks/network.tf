resource "azurerm_network_security_group" "tf-demo-nsg" {
  name                = "tf-demo-nsg"
  location            = azurerm_resource_group.tf-demo-rg.location
  resource_group_name = azurerm_resource_group.tf-demo-rg.name
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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
}

resource "azurerm_subnet" "tf-demo-subnet2" {
  name                 = "tf-demo-subnet2"
  resource_group_name  = azurerm_resource_group.tf-demo-rg.name
  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.tf-demo-vnet.name
}

resource "azurerm_route_table" "tf-demo-rt-table" {
  name                = "tf-demo-rt-table"
  location            = azurerm_resource_group.tf-demo-rg.location
  resource_group_name = azurerm_resource_group.tf-demo-rg.name
  route {
    name                   = "tf-demo-route"
    address_prefix         = "10.0.0.0/16"
    next_hop_type          = "Internet" 
    next_hop_in_ip_address   = "0.0.0.0/0"    
    }
}

resource "azurerm_subnet_route_table_association" "tf-demo-subnet1-rt-association" {
  subnet_id      = azurerm_subnet.tf-demo-subnet1.id
  route_table_id = azurerm_route_table.tf-demo-rt-table.id  
}

resource "azurerm_subnet_route_table_association" "tf-demo-subnet2-rt-association" {
  subnet_id      = azurerm_subnet.tf-demo-subnet2.id
  route_table_id = azurerm_route_table.tf-demo-rt-table.id  
}

resource "azurerm_subnet_network_security_group_association" "tf-demo-subnet1-nsg-association" {
  subnet_id = azurerm_subnet.tf-demo-subnet1.id
  network_security_group_id = azurerm_network_security_group.tf-demo-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "tf-demo-subnet2-nsg-association" {
  subnet_id = azurerm_subnet.tf-demo-subnet2.id
  network_security_group_id = azurerm_network_security_group.tf-demo-nsg.id
}