output "kubernetes_fqdn" {
  value       = "${azurerm_kubernetes_cluster.default.fqdn}"
  description = "FQDN of kubernetes"
}

output "kubernetes_kubeconfig" {
  value       = "${azurerm_kubernetes_cluster.default.kube_config_raw}"
  description = "Kubeconfig"
}
