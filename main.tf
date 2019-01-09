terraform {
  required_version = "~>0.11.0"
}

provider "azurerm" {
  version = "~>1.20.0"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-adsy-demo-meetup-01"
  location = "westeurope"

  tags {
    origin      = "${var.tags["origin"]}"
    customer    = "${var.tags["customer"]}"
    environment = "${var.tags["environment"]}"
    owner       = "${var.tags["owner"]}"
  }
}

resource "azurerm_azuread_application" "aks_ad_app" {
  name     = "app-adsy-demo-meetup-01"
  homepage = "https://aks-adsy-demo-meetup-01.intra"
}

resource "azurerm_azuread_service_principal" "aks_ad_sp" {
  application_id = "${azurerm_azuread_application.aks_ad_app.application_id}"
}

resource "azurerm_azuread_service_principal_password" "aks_ad_sp" {
  service_principal_id = "${azurerm_azuread_service_principal.aks_ad_sp.id}"
  value                = "${var.aks_ad_sp_password}"
  end_date             = "${var.aks_ad_sp_end_date}"
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-adsy-demo-meetup-01"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  dns_prefix          = "meetupbern"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_DS1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 10
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    origin      = "${var.tags["origin"]}"
    customer    = "${var.tags["customer"]}"
    environment = "${var.tags["environment"]}"
    owner       = "${var.tags["owner"]}"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.default.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.default.kube_config_raw}"
}
