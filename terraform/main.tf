resource "azurerm_resource_group" "main" {
  name     = var.name
  location = "West Europe"
}

##
# Database
##
resource "random_pet" "database_username" {
  separator = ""
}
resource "random_password" "database_password" {
  length  = 16
  special = false
}
resource "azurerm_postgresql_server" "main" {
  name                = var.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  administrator_login          = random_pet.database_username.id
  administrator_login_password = random_password.database_password.result

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

data "azurerm_container_registry_scope_map" "main" {
  name                    = "_repositories_pull"
  resource_group_name     = azurerm_resource_group.main.name
  container_registry_name = azurerm_container_registry.main.name
}

resource "azurerm_container_registry_token" "main" {
  name                    = var.name
  container_registry_name = azurerm_container_registry.main.name
  resource_group_name     = azurerm_resource_group.main.name
  scope_map_id            = data.azurerm_container_registry_scope_map.main.id
}

resource "azurerm_container_registry_token_password" "main" {
  container_registry_token_id = azurerm_container_registry_token.main.id

  password1 {
  }
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

  secret {
    name  = "registry-token"
    value = one(azurerm_container_registry_token_password.main.password1).value
  }

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry_token.main.name
    password_secret_name = "registry-token"
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  secret {
    name  = "db-username"
    value = "${random_pet.database_username.id}@${azurerm_postgresql_server.main.name}"
  }

  secret {
    name  = "db-password"
    value = random_password.database_password.result
  }

  template {
    container {
      name   = "maincontainerapp"
      image  = var.image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_server.main.fqdn
      }
      env {
        name  = "DB_SSLMODE"
        value = "require"
      }
      env {
        name        = "DB_USER"
        secret_name = "db-username"
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }

      liveness_probe {
        path      = "/health"
        port      = 8080
        transport = "HTTP"
      }

      readiness_probe {
        path      = "/health"
        port      = 8080
        transport = "HTTP"
      }
    }
  }
}
