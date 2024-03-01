resource "azurerm_resource_group" "main" {
  name     = var.name
  location = "West Europe"
}

##
# Database
##
resource "azurerm_postgresql_server" "main" {
  name                = var.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

##
# Container Registry
##
resource "azurerm_container_registry" "main" {
  name                = replace(var.name, "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
}

##
# Application
##
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = var.name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}
resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "maincontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
