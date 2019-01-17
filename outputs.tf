output "address" {
  value       = "${azurerm_kubernetes_cluster.default.fqdn}"
  description = "FQDN of kubernetes"
}
