# References

## Terraform azurerm docs used throughout this project

* azurerm_resource_group: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
* azurerm_virtual_network: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
* azurerm_subnet: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
* azurerm_network_security_group: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
* azurerm_network_security_rule: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
* azurerm_subnet_network_security_group_association: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
* azurerm_private_dns_zone: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone
* azurerm_private_dns_zone_virtual_network_link: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link
* azurerm_storage_account: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
* azurerm_storage_share: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
* azurerm_mysql_flexible_server: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server
* azurerm_mysql_flexible_database: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_database
* azurerm_mysql_flexible_server_configuration: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_configuration
* azurerm_private_endpoint: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
* azurerm_log_analytics_workspace: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
* azurerm_application_insights: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
* azurerm_service_plan: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
* azurerm_linux_web_app: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app
* azurerm_user_assigned_identity: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
* azurerm_container_registry: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
* azurerm_role_assignment: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
* azurerm_key_vault: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
* azurerm_key_vault_secret: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
* azurerm_management_lock: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock
* azurerm_policy_definition (data source): https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition
* azurerm_resource_group_policy_assignment: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment
* azurerm_resource_group_policy_remediation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_remediation
* azurerm_monitor_diagnostic_setting: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
* azurerm_consumption_budget_resource_group: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group
* azurerm_monitor_metric_alert: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert
* azurerm_recovery_services_vault: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault
* azurerm_backup_policy_file_share: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share
* azurerm_backup_container_storage_account: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account
* azurerm_backup_protected_file_share: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share
* azurerm_monitor_scheduled_query_rules_alert_v2: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2
* azurerm_federated_identity_credential: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential
* azurerm_client_config (data source): https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config

## Other Terraform providers

* random_string: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string

## Microsoft docs referenced during the build

* MySQL Flexible Server metrics: https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-monitoring
* MySQL Flexible Server TLS/SSL: https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-connect-tls-ssl
* MySQL Flexible Server certificate rotation: https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-root-certificate-rotation
* Azure Backup pricing (Files, Snapshot Management): https://azure.microsoft.com/en-us/pricing/details/backup/
* Application Insights auto-instrumentation overview: https://learn.microsoft.com/en-us/azure/azure-monitor/app/codeless-overview
* Application Insights custom events API (v2/track): https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-api-custom-events-metrics
* GitHub Actions OIDC with Azure: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure
* Azure Policy "Allowed locations" built-in definition: https://learn.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage
* Azure Database Migration Service overview: https://learn.microsoft.com/en-us/azure/dms/dms-overview
* Azure Database Migration Service, MySQL migration tutorial: https://learn.microsoft.com/en-us/azure/dms/tutorial-mysql-azure-mysql-offline-portal

## Well-Architected Framework and Cloud Adoption Framework

* HashiCorp Well-Architected Framework, tagging strategy: https://developer.hashicorp.com/well-architected-framework/optimize-systems/lifecycle-management/tag-cloud-resources
* Microsoft Cloud Adoption Framework, tagging strategy: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging

## Community/GitHub sources, worth double checking myself

* terraform-provider-azurerm issues (federated_identity_credential parent_id deprecation, container_registry_managed_identity_client_id): https://github.com/hashicorp/terraform-provider-azurerm/issues
* terraform-provider-azurerm default_tags feature request (confirms it does not exist): https://github.com/hashicorp/terraform-provider-azurerm/issues/19135
* microsoft/ApplicationInsights-PHP (archived, confirms SDK abandonment): https://github.com/microsoft/ApplicationInsights-PHP
* HashiCorp GitHub issue: azurerm_management_lock should be applied once all other resources are deployed: https://github.com/hashicorp/terraform-provider-azurerm/issues/5473
* HashiCorp GitHub issue: Management Locks need a better lifecycle support: https://github.com/hashicorp/terraform-provider-azurerm/issues/23768