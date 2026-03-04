resource "azurerm_kubernetes_cluster" "aks-demo-cluster" {
  name                = "aks-demo-cluster"
  location            = azurerm_resource_group.aks-demo-rg.location
  resource_group_name = azurerm_resource_group.aks-demo-rg.name
  dns_prefix          = "aksdemo"
  oidc_issuer_enabled = true
  sku_tier            = "Free"
  support_plan        = "KubernetesOfficial"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_B4als_v2"
    enable_auto_scaling = true
    min_count  = 2
    max_count  = 3
    node_count = 2
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  linux_profile {
    admin_username = "azureadmin"

    ssh_key {
      key_data = file("./infra-controller_key")
    }
  }
}