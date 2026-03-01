resource "azurerm_kubernetes_cluster" "demo_aks_cluster" {
  name                = "demo_aks_cluster"
  location            = "central india"
  resource_group_name = "eos"

  default_node_pool {
    name       = "demo_node_pool"
    node_count = 1
    vm_size    = "Standard_B4als_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.demo_aks_cluster.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.demo_aks_cluster.kube_config_raw
  sensitive = true
}