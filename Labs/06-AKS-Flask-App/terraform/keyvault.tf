data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name = "${var.prefix}-kv"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = var.key_vault_sku

  purge_protection_enabled = false
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge"
  ]
}