provider "helm" {
  version = "~>0.7"

  kubernetes {
    host                   = "${azurerm_kubernetes_cluster.default.kube_config.0.host}"
    username               = "${azurerm_kubernetes_cluster.default.kube_config.0.username}"
    password               = "${azurerm_kubernetes_cluster.default.kube_config.0.password}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)}"
  }
}

resource "helm_release" "consul" {
  name      = "consul"
  chart     = "stable/consul"
  namespace = "consul"
}
