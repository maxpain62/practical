resource "azurerm_kubernetes_cluster_node_pool" "demo-nodepool" {
  name                  = "demonodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-demo-cluster.id
  vm_size               = "Standard_B4als_v2"
  auto_scaling_enabled  = true
  min_count             = 2
  max_count             = 3

}