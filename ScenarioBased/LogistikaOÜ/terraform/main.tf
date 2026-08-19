terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "sandertfstate"
    container_name = "tfstate"
    key = "logistikaou.terraform.tfstate"
    use_azuread_auth = true
  }

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 4.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}   

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false 
    }
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length = 5
  lower = true
  upper = false
  special = false 
}


resource "azurerm_resource_group" "LogistikaOU" {
  name = "${var.prefix}-rg"
  location = var.location

  tags = {
    CostCenter = "Infrastructure"
    Environment = "LogistikaOU"
    Owner = "Architect"
    Application = "FleetTracker"
  }
}

resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-vnet"
  address_space = [var.vnet_address_space]
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_subnet" "appservice" {
  name = "${var.prefix}-snet-appservice"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.appservice_subnet_prefix]

  delegation {
    name = "appservice-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private-endpoints" {
  name = "${var.prefix}-snet-pe"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.pe_subnet_prefix]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "mysql-server" {
  name = "${var.prefix}-sql"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.mysql_subnet_prefix]

  delegation {
    name = "sql"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "PE-nsg" {
  name = "${var.prefix}-nsg-pe"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_network_security_group" "SQL-nsg" {
  name = "${var.prefix}-nsg-sql"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_network_security_rule" "Inbound-MySQL" {
  name = "Allow-MySQL"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3306"
  source_address_prefix = var.appservice_subnet_prefix /// AppService
  destination_address_prefix = var.mysql_subnet_prefix /// MySQL server subnet
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  network_security_group_name = azurerm_network_security_group.SQL-nsg.name
}

resource "azurerm_network_security_rule" "Inbound-AzureFiles" {
  name = "AllowAz-Files"
  priority = 200
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "445"
  source_address_prefix = var.appservice_subnet_prefix /// AppService
  destination_address_prefix = var.pe_subnet_prefix ///Private endpoint subnet
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  network_security_group_name = azurerm_network_security_group.PE-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "pe-subn-nsg-assoc" {
  subnet_id = azurerm_subnet.private-endpoints.id
  network_security_group_id = azurerm_network_security_group.PE-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "sql-subn-nsg-assoc" {
  subnet_id = azurerm_subnet.mysql-server.id
  network_security_group_id = azurerm_network_security_group.SQL-nsg.id
}

resource "azurerm_private_dns_zone" "MySQL" {
  name = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "MySQL-link" {
  name = "Database"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  private_dns_zone_name = azurerm_private_dns_zone.MySQL.name
  virtual_network_id = azurerm_virtual_network.main.id
  registration_enabled = false

  lifecycle {
    ignore_changes = [ tags
     ]
  }
}

resource "azurerm_private_dns_zone" "AzureFiles" {
  name = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "AzFiles" {
  name = "Fileshare"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  private_dns_zone_name = azurerm_private_dns_zone.AzureFiles.name
  virtual_network_id = azurerm_virtual_network.main.id
  registration_enabled = false

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_zone" "KeyVault" {
  name = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "KvLink" {
  name = "Keyvault"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  private_dns_zone_name = azurerm_private_dns_zone.KeyVault.name
  virtual_network_id = azurerm_virtual_network.main.id
  registration_enabled = false

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_storage_account" "LogistikaST" {
  name = "${var.storage_prefix}${random_string.random.result}"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  location = azurerm_resource_group.LogistikaOU.location
  account_kind = "StorageV2"
  account_tier = "Standard"
  account_replication_type = "ZRS"
  min_tls_version = "TLS1_2"
  public_network_access_enabled = false 

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_storage_share" "Employees" {
  name = "employeedata"
  storage_account_id = azurerm_storage_account.LogistikaST.id
  quota = 1024
  enabled_protocol = "SMB"
  access_tier = "Cool"
}

resource "azurerm_mysql_flexible_server" "FleetTrackerData" {
  name = "fleetappdata"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  location = azurerm_resource_group.LogistikaOU.location
  administrator_login = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  backup_retention_days = 30
  delegated_subnet_id = azurerm_subnet.mysql-server.id
  private_dns_zone_id = azurerm_private_dns_zone.MySQL.id
  sku_name = "B_Standard_B1ms"
  depends_on = [ azurerm_private_dns_zone_virtual_network_link.MySQL-link ]

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_mysql_flexible_database" "fleetdatabase" {
  name = "fleettrackerdb"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  server_name = azurerm_mysql_flexible_server.FleetTrackerData.name
  charset = "utf8mb4"
  collation = "utf8mb4_0900_ai_ci"
}

resource "azurerm_private_endpoint" "AzFiles" {
  name = "fileshare-endpoint"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  subnet_id = azurerm_subnet.private-endpoints.id
  depends_on = [ azurerm_private_dns_zone_virtual_network_link.AzFiles ]

  lifecycle {
    ignore_changes = [ tags ]
  }

  private_service_connection {
    name = "fileshare-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.LogistikaST.id
    subresource_names = ["file"]
    is_manual_connection = false 
  }
  private_dns_zone_group {
    name = "fileshare-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.AzureFiles.id]
  }
}

resource "azurerm_private_endpoint" "KeyVault" {
  name = "keyvault-endpoint"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  subnet_id = azurerm_subnet.private-endpoints.id
  depends_on = [ azurerm_private_dns_zone_virtual_network_link.KvLink ]

  lifecycle {
    ignore_changes = [ tags ]
  }

  private_service_connection {
    name = "keyvault-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names = ["vault"]
    is_manual_connection = false
  }
  private_dns_zone_group {
    name = "keyvault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.KeyVault.id]
  }
}

resource "azurerm_log_analytics_workspace" "FleetLogs" {
  name = "fleetapplogs"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  sku = "PerGB2018"
  retention_in_days = 30

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_application_insights" "fleetinsights" {
  name = "fleet-app-insights"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  workspace_id = azurerm_log_analytics_workspace.FleetLogs.id
  application_type = "other"

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_service_plan" "FleetAppPlan" {
  name = "fleetrackerplan"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  location = azurerm_resource_group.LogistikaOU.location
  os_type = "Linux"
  sku_name = "B2"

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_linux_web_app" "FleetTrackerApp" {
  name = "logistikaou-fleettracker"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  location = azurerm_service_plan.FleetAppPlan.location
  service_plan_id = azurerm_service_plan.FleetAppPlan.id
  virtual_network_subnet_id = azurerm_subnet.appservice.id
  key_vault_reference_identity_id = azurerm_user_assigned_identity.keyvault.id

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr.id, azurerm_user_assigned_identity.keyvault.id]
  }

  lifecycle {
    ignore_changes = [ tags ]
  }

  site_config {
    container_registry_use_managed_identity = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.acr.client_id

    application_stack {
      docker_image_name = "fleettracker:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    MySQL_Host = azurerm_mysql_flexible_server.FleetTrackerData.fqdn
    MySQL_Username = var.mysql_admin_username
    MySQL_Password = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.DbCreds.versionless_id})"
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.fleetinsights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }
}

resource "azurerm_user_assigned_identity" "acr" {
  location = azurerm_resource_group.LogistikaOU.location
  name = "acrpull"
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_user_assigned_identity" "github_actions" {
  location = azurerm_resource_group.LogistikaOU.location
  name = "github-actions_cicd"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
}

resource "azurerm_container_registry" "acr" {
  name = "contReg${random_string.random.result}"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  location = azurerm_resource_group.LogistikaOU.location
  sku = "Basic"
  admin_enabled = false

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_role_assignment" "Acr" { 
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_user_assigned_identity.acr.principal_id
}

resource "azurerm_role_assignment" "GitActionsAcrPush" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id = azurerm_user_assigned_identity.github_actions.principal_id
}

resource "azurerm_role_assignment" "GitActionsReader" {
  scope = azurerm_resource_group.LogistikaOU.id
  role_definition_name = "Reader"
  principal_id = azurerm_user_assigned_identity.github_actions.principal_id
}

resource "azurerm_role_assignment" "KvSecrUser" { 
  scope = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id = azurerm_user_assigned_identity.keyvault.principal_id
}

resource "azurerm_role_assignment" "KvSecrOfficer" {
  scope = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "TagContributor" {
  scope = azurerm_resource_group.LogistikaOU.id
  role_definition_name = "Tag Contributor"
  principal_id = azurerm_user_assigned_identity.tag_inherit.principal_id
}

/*
resource "azurerm_role_assignment" "Contributor" {
  scope = azurerm_resource_group.LogistikaOU.id
  role_definition_name = "Contributor"
  principal_id = var.it_admin_object_id
}
*/

resource "azurerm_key_vault" "kv" {
  name = "logOUkeyVault${random_string.random.result}"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  rbac_authorization_enabled = true
  enabled_for_disk_encryption = false
  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = true
  public_network_access_enabled = true
  
  sku_name = "standard"

  lifecycle {
    ignore_changes = [ tags ]
  }

  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    ip_rules = var.deployer_ip
  }
}

resource "azurerm_key_vault_secret" "DbCreds" {
  name = "mysql-admin-pw"
  value = var.mysql_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_role_assignment.KvSecrOfficer ]
}

resource "azurerm_user_assigned_identity" "keyvault" {
  location = azurerm_resource_group.LogistikaOU.location
  name = "KVuser"
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_user_assigned_identity" "tag_inherit" {
  location = azurerm_resource_group.LogistikaOU.location
  name = "tag-inherit-identity"
  resource_group_name = azurerm_resource_group.LogistikaOU.name

  lifecycle {
    ignore_changes = [ tags ]
  }
}

/*
resource "azurerm_management_lock" "rg-level" { /// Commented out for active development, lock at RG level blocks TF destroy since it tracks locks dependency on the RG.
  name = "rg-level-cantdel"
  scope = azurerm_resource_group.LogistikaOU.id
  lock_level = "CanNotDelete"
  notes = "Prevents accidental deletion of the RG and resources within it. Remove ONLY with deliberate intent, contact architect first"
}
*/ 

data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "inherit_tag" {
  display_name = "Inherit a tag from the resource group"
}

resource "azurerm_resource_group_policy_assignment" "inherit_tags" {
  for_each = toset(["CostCenter", "Environment", "Owner", "Application"])

  name = "inherit-${lower(each.value)}-tag"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_id = azurerm_resource_group.LogistikaOU.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag.id

  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.tag_inherit.id]
  }

  parameters = jsonencode({
    tagName = { value = each.value }
  })

  depends_on = [ azurerm_role_assignment.TagContributor ]
}

resource "azurerm_resource_group_policy_remediation" "inherit-tags-remediation" {
  for_each = azurerm_resource_group_policy_assignment.inherit_tags

  name = "remediate-${lower(each.key)}-tag"
  resource_group_id = azurerm_resource_group.LogistikaOU.id
  policy_assignment_id = each.value.id
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name = "allowed_locations"
  resource_group_id = azurerm_resource_group.LogistikaOU.id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  parameters = jsonencode({
    listOfAllowedLocations = { value= ["westeurope"]}
  })
}

resource "azurerm_monitor_diagnostic_setting" "kv_audit" {
  name = "kv-audit-logs"
  target_resource_id = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.FleetLogs.id

  enabled_log {
    category = "AuditEvent"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_audit" {
  name = "st-audit_logs"
  target_resource_id = "${azurerm_storage_account.LogistikaST.id}/fileServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.FleetLogs.id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
}

resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name = "audit_log_enabled"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  server_name = azurerm_mysql_flexible_server.FleetTrackerData.name
  value = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  name = "audit_log_events"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  server_name = azurerm_mysql_flexible_server.FleetTrackerData.name
  value = "CONNECTION,ADMIN,DCL,DDL,DML"
}

resource "azurerm_monitor_diagnostic_setting" "mysql_audit" {
  name = "mysql-audit-logs"
  target_resource_id = azurerm_mysql_flexible_server.FleetTrackerData.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.FleetLogs.id

  enabled_log {
    category = "MySqlAuditLogs"
  }
}

resource "azurerm_consumption_budget_resource_group" "rg-level-consumption" {
  name = "rg-cost-month"
  resource_group_id = azurerm_resource_group.LogistikaOU.id

  amount = 200
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("2026-08-01'T'hh:mm:ssZ", timestamp())
  }

  notification {
    enabled = true
    threshold = 80.0
    operator = "GreaterThan"
    contact_roles = [ "Owner" ]
  }

  notification {
    enabled = true
    threshold = 100.0
    operator = "GreaterThan"
    contact_roles = [ "Owner" ]
  }

  lifecycle {
    ignore_changes = [ time_period ]
  }
}

resource "azurerm_monitor_metric_alert" "response_time_alert" {
  name = "avg-response-time-alert"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  scopes = [ azurerm_linux_web_app.FleetTrackerApp.id ]
  description = "Fires if AVG response time exceeds 5 sec over a 5 min windows"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name = "AverageResponseTime"
    aggregation = "Average"
    operator = "GreaterThan"
    threshold = 5
  }

  lifecycle {
    ignore_changes = [ tags ]
  }

  window_size = "PT5M"
  frequency = "PT1M"
}

resource "azurerm_monitor_metric_alert" "mysql_cpu_alert" {
  name = "mysql-cpu-alert"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  scopes = [ azurerm_mysql_flexible_server.FleetTrackerData.id ]
  description = "Fires when avg CPU exceeds 80% over 15 mins"
  severity = 2

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/flexibleServers"
    metric_name = "cpu_percent"
    aggregation = "Average"
    operator = "GreaterThan"
    threshold = 80
  }

  lifecycle {
    ignore_changes = [ tags ]
  }

  window_size = "PT15M"
  frequency = "PT5M"
}

resource "azurerm_monitor_metric_alert" "mysql-storage-used-alert" {
  name = "mysql-storage-alert"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  scopes = [ azurerm_mysql_flexible_server.FleetTrackerData.id ]
  description = "Fires when storage reaches 80% of total capacity"
  severity = 2

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/flexibleServers"
    metric_name = "storage_percent"
    aggregation = "Average"
    operator = "GreaterThan"
    threshold = 80
  }

  lifecycle {
    ignore_changes = [ tags ]
  }

  window_size = "PT1H"
  frequency = "PT15M"
}

resource "azurerm_monitor_metric_alert" "storage_capacity_alert" {
  name = "storage-capacity-alert"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  scopes = [ azurerm_storage_account.LogistikaST.id ]
  description = "Fires when storage used capacity exceeds 800Gb, warning before 1Tb"
  severity = 2

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name = "UsedCapacity"
    aggregation = "Average"
    operator = "GreaterThan"
    threshold = 858993459200
  }

  lifecycle {
    ignore_changes = [ tags ]
  }
  
  window_size = "PT1H"
  frequency = "PT15M"
}

resource "azurerm_recovery_services_vault" "azfiles-backup" {
  name = "AZfiles-backup"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  sku = "Standard"

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_backup_policy_file_share" "backup-policy" {
  name = "fileshare-vaultRec-policy"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  recovery_vault_name = azurerm_recovery_services_vault.azfiles-backup.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time = "23:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count = 2
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count = 3
    weekdays = ["Sunday"]
    weeks = [ "Last" ]
  }

  retention_yearly {
    count = 1
    weekdays = ["Sunday"]
    weeks = ["Last"]
    months = ["January"]
  }
}

resource "azurerm_backup_container_storage_account" "protection-container" {
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  recovery_vault_name = azurerm_recovery_services_vault.azfiles-backup.name
  storage_account_id = azurerm_storage_account.LogistikaST.id
}

resource "azurerm_backup_protected_file_share" "mainshare" {
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  recovery_vault_name = azurerm_recovery_services_vault.azfiles-backup.name
  source_storage_account_id = azurerm_backup_container_storage_account.protection-container.storage_account_id
  source_file_share_name = azurerm_storage_share.Employees.name
  backup_policy_id = azurerm_backup_policy_file_share.backup-policy.id

  depends_on = [ azurerm_backup_container_storage_account.protection-container ]
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "log-analytics_ingestion" {
  name = "log-analytics-ingestion-alert"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  location = azurerm_resource_group.LogistikaOU.location
  scopes = [ azurerm_log_analytics_workspace.FleetLogs.id ]
  description = "Fires when data ingestion reaches 4Gb"
  severity = 2
  evaluation_frequency = "P1D"
  window_duration = "P1D"

  lifecycle {
    ignore_changes = [ tags ]
  }

  criteria {
    query = <<-EOT
    Usage
    | where TimeGenerated > ago(24h)
    | where IsBillable == true
    | summarize IngestedGB = sum(Quantity) / 1000
    EOT

    time_aggregation_method = "Maximum"
    threshold = 4
    operator = "GreaterThan"

    metric_measure_column = "IngestedGB"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods = 1
    }
  }
}

resource "azurerm_federated_identity_credential" "github_actions" {
  name = "github-actions-federated-credential"
  user_assigned_identity_id = azurerm_user_assigned_identity.github_actions.id
  audience = ["api://AzureADTokenExchange"]
  issuer = "https://token.actions.githubusercontent.com"
  subject = "repo:PelmeenidHapukoorega/Azure-Lab-Automation:ref:refs/heads/main"
}