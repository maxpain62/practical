resource "azurerm_kubernetes_cluster" "tf-demo-aks-cluster" {
  name = "tf-demo-aks-cluster"
  location = azurerm_resource_group.tf-demo-rg.location
  resource_group_name = azurerm_resource_group.tf-demo-rg.name
  oidc_issuer_enabled = true
  sku_tier = "Free"
  support_plan = "KubernetesOfficial"
  dns_prefix = "tf-demo-aks-cluster"

  default_node_pool {
    name = "demonodepool"
    node_count = 3
    vm_size = "Standard_B2as_v2" 
    vnet_subnet_id = azurerm_subnet.tf-demo-subnet1.id
  }

  identity {
    type = "SystemAssigned"
  }
  
  linux_profile {
    admin_username = "azureadmin"

    ssh_key {
      key_data = file("./infra-controller_key")
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    # MUST NOT overlap with 10.0.0.0/16
    service_cidr       = "10.100.0.0/16"
    dns_service_ip     = "10.100.0.10"
  }
}