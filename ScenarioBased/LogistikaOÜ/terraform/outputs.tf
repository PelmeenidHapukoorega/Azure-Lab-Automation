output "resource_group_name" {
  description = "Name of the RG"
  value = azurerm_resource_group.LogistikaOU.name
}

output "vnet_id" {
  description = "Id of Logistikas virtual network"
  value = azurerm_virtual_network.main.id
}

output "appservice_subnet_id" {
  description = "Id of appservices delegated subnet"
  value = azurerm_subnet.appservice.id
}

output "mysql_subnet_id" {
  description = "Id of MySql delegated subnet"
  value = azurerm_subnet.mysql-server.id
}

output "private_endpoints_subnet_id" {
  description = "Id of shared PE subnet (Storage and KV)"
  value = azurerm_subnet.private-endpoints.id
}

output "storage_account_name" {
  description = "azurerm_storage_account.LogistikaST.id"
  value = azurerm_storage_account.LogistikaST.name
}

output "storage_account_id" {
  description = "Resource ID of the ST account"
  value = azurerm_storage_account.LogistikaST.id
}

output "file_share_name" {
  description = "Name of AZ files share"
  value = azurerm_storage_share.Employees.name
}

output "mysql_server_name" {
  description = "Name of mysql flexibile server"
  value = azurerm_mysql_flexible_server.FleetTrackerData.name
}

output "mysql_fqdn" {
  description = "Qualified domain name of the mysql server"
  value = azurerm_mysql_flexible_server.FleetTrackerData.fqdn
}

output "key_vault_name" {
  description = "Name of KV"
  value = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI of KV"
  value = azurerm_key_vault.kv.vault_uri
}

output "mysql_secret_versionless_id" {
  description = "Versionless ID of the MySql admin pw secret in KV"
  value = azurerm_key_vault_secret.DbCreds.versionless_id
}

output "app_service_name" {
  description = "Name of appservice"
  value = azurerm_linux_web_app.FleetTrackerApp.name
}

output "app_service_default_hostname" {
  description = "Default public hostname of the appservice"
  value = azurerm_linux_web_app.FleetTrackerApp.default_hostname
}

output "acr_login_server" {
  description = "Login server URL for the registry, used by CI/CD to push images"
  value = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "Name of container registry"
  value = azurerm_container_registry.acr.name
}

output "log_analytics_workspace_id" {
  description = "ID of analytics workspace"
  value = azurerm_log_analytics_workspace.FleetLogs.id
}

output "application_insights_connection_string" {
  description = "App insights connection string (for wiring external tools)"
  value = azurerm_application_insights.fleetinsights.connection_string
  sensitive = true
}