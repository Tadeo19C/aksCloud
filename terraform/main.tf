ndica que Terraform está intentando usar la suscripción antigua (493b052c...) en lugar de la nueva (dee699d6...).

Esto sucede porque locals {
  rg_name   = "${var.prefix}-rg"
  vnet_name = "${var.prefix}-vnet-wu2"
  aks_name  = "${var.prefix}-aks"
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "${var.prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"

  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "nodepool1"
    vm_size         = var.vm_size
    node_count      = var.node_count
    vnet_subnet_id  = azurerm_subnet.aks.id
    os_disk_size_gb = 64
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    outbound_type  = "loadBalancer"
  }

  # Si se define var.kubernetes_version, se aplica aquí
  lifecycle {
    ignore_changes = [kubernetes_version]
  }
}
