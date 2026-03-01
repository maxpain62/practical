resource "azurerm_public_ip" "demo_public_ip" {
  name                = "demo-public-ip"
  location            = "Central India"
  resource_group_name = "eos"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "demo_network_interface" {
  name                = "demo-network-interface"
  location            = "Central India"
  resource_group_name = "eos"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/3317ca74-0e1e-428c-a67b-45d7d2344bfc/resourceGroups/eos/providers/Microsoft.Network/virtualNetworks/vnet-centralindia/subnets/snet-centralindia-1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo_public_ip.id
  }
}

resource "azurerm_network_security_group" "demo_nsg" {
  name                = "demo-nsg"
  location            = "Central India"
  resource_group_name = "eos"

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "demo_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.demo_network_interface.id
  network_security_group_id = azurerm_network_security_group.demo_nsg.id
}

resource "azurerm_ssh_public_key" "demo_public_key" {
  name                = "demo-public-key"
  resource_group_name = "eos"
  location            = "Central India"
  public_key          = file("./infra-controller_key")
}

resource "azurerm_linux_virtual_machine" "demo_vm" {
  name                            = "demo-vm"
  resource_group_name             = "eos"
  location                        = "Central India"
  size                            = "Standard_B2als_v2"
  network_interface_ids           = [azurerm_network_interface.demo_network_interface.id]
  admin_username                  = "ubuntu"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "ubuntu"
    public_key = azurerm_ssh_public_key.demo_public_key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("./terraform_installation.sh")
}

resource "azurerm_role_assignment" "demo_role_assignment" {
  principal_id         = azurerm_linux_virtual_machine.demo_vm.identity[0].principal_id
  principal_type       = "ServicePrincipal"
  role_definition_name = "Contributor"
  scope                = "subscriptions/3317ca74-0e1e-428c-a67b-45d7d2344bfc"
}


output "vm_public_ip" {
  value = azurerm_public_ip.demo_public_ip.ip_address
}