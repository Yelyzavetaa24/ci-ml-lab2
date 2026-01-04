terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  student_id = "50255"
  location   = "francecentral"

  rg_name  = "rg-aml-${local.student_id}"
  sa_name  = "staml${local.student_id}"
  kv_name  = "kv${local.student_id}"
  acr_name = "acraml${local.student_id}"
  la_name  = "la-aml-${local.student_id}"
  ai_name  = "ai-aml-${local.student_id}"
  ws_name  = "amlws-${local.student_id}"
}

resource "azurerm_resource_group" "aml" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_log_analytics_workspace" "aml" {
  name                = local.la_name
  location            = local.location
  resource_group_name = azurerm_resource_group.aml.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "aml" {
  name                = local.ai_name
  location            = local.location
  resource_group_name = azurerm_resource_group.aml.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.aml.id
}

resource "azurerm_storage_account" "aml" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.aml.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_container_registry" "aml" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.aml.name
  location            = local.location
  sku                 = "Basic"
  admin_enabled       = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "aml" {
  name                        = local.kv_name
  location                    = local.location
  resource_group_name         = azurerm_resource_group.aml.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.aml.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "Set", "List", "Delete"]
}

resource "azurerm_machine_learning_workspace" "aml" {
  name                    = local.ws_name
  location                = local.location
  resource_group_name     = azurerm_resource_group.aml.name
  application_insights_id = azurerm_application_insights.aml.id
  key_vault_id            = azurerm_key_vault.aml.id
  storage_account_id      = azurerm_storage_account.aml.id
  container_registry_id   = azurerm_container_registry.aml.id

  identity {
    type = "SystemAssigned"
  }
}

output "aml_portal_url" {
  value = "https://ml.azure.com/?wsid=${azurerm_machine_learning_workspace.aml.id}"
}

output "aml_workspace_name" {
  value = azurerm_machine_learning_workspace.aml.name
}
