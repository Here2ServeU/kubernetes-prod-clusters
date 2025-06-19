output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_admin_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}