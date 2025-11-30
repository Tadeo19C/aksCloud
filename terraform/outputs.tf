output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "aks_name" {
  description = "Nombre del clúster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kubeconfig" {
  description = "Kubeconfig del clúster (sensitivo)"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}
