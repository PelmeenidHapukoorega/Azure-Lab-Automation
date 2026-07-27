# Lab 10: Grafana

Azure Managed Grafana connected to an existing Log Analytics workspace, visualizing real AKS metrics from Lab 06.

## Demo

<!-- Demo video coming soon -->

## What this deploys

- Azure Managed Grafana instance (Standard SKU)
- System-assigned managed identity for Grafana
- Monitoring Reader role assignment at subscription scope
- Data source connected to Lab 06's Log Analytics workspace

## Tech stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform |
| Visualization | Azure Managed Grafana |
| Data source | Azure Monitor via Log Analytics |
| Auth | System-assigned managed identity |

## Key decisions

**Azure Managed Grafana over self-hosted** — native Azure AD integration, no server to manage, Terraform deployable.

**Subscription-scoped Monitoring Reader** — workspace-scoped wasn't enough. Grafana needs to discover and read metrics from Azure resources directly, not just query the workspace.

**System-assigned identity** — tied to Grafana's lifecycle, automatic cleanup on destroy, no need to share across resources.

## How to run

Deploy Lab 06 first so the Log Analytics workspace exists:
```bash
cd Labs/06-SimpleMetrics-AKS/terraform
terraform apply -auto-approve
```

Then deploy Lab 10:
```bash
cd Labs/10-Grafana/terraform
terraform init
terraform apply -auto-approve
```

Access Grafana via the endpoint output. Add Azure Monitor as a data source and build dashboards against your AKS metrics.

**Destroy when done (both labs):**
```bash
cd Labs/10-Grafana/terraform && terraform destroy -auto-approve
cd Labs/06-SimpleMetrics-AKS/terraform && terraform destroy -auto-approve
```

## Notes

Full debugging process and decisions documented in [LEARNINGS.md](./LEARNINGS.md).