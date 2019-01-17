terraform {
  required_version = "~>0.11.0"

  backend "local" {
    path = "./meetup.tfstate"
  }
}

provider "azurerm" {
  version = "~>1.21.0"
}

provider "azuread" {
  version = "~>0.1"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-adsy-demo-meetup-01"
  location = "${var.location}"

  tags {
    origin   = "${var.tags["origin"]}"
    customer = "${var.tags["customer"]}"
    env      = "${var.tags["environment"]}"
    owner    = "${var.tags["owner"]}"
  }
}

resource "azuread_application" "aks_ad_app" {
  name     = "app-adsy-demo-meetup-01"
  homepage = "https://aks-adsy-demo-meetup-01.intra"
}

resource "azuread_service_principal" "aks_ad_sp" {
  application_id = "${azuread_application.aks_ad_app.application_id}"
}

resource "azuread_service_principal_password" "aks_ad_sp" {
  service_principal_id = "${azuread_service_principal.aks_ad_sp.id}"
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
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${azuread_application.aks_ad_app.application_id}"
    client_secret = "${var.aks_ad_sp_password}"
  }

  tags {
    origin   = "${var.tags["origin"]}"
    customer = "${var.tags["customer"]}"
    env      = "${var.tags["environment"]}"
    owner    = "${var.tags["owner"]}"
  }
}

resource "local_file" "kubeconfig" {
  filename = "./kubeconfig"
  content  = "${azurerm_kubernetes_cluster.default.kube_config_raw}"
}
