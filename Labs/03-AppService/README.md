# Lab 03: App Service Deployment

Deploy Azure App Service environment using Bicep modules: Includes a storage account and a web app, with environment-aware configuration that automatically adjusts SKUs between non-production and production.

## What this deploys

| Resource | Name | Purpose |
|----------|------|---------|
| Storage Account | toylaunch{unique} | StorageV2, Hot tier = SKU changes based on environment |
| App Service Plan | toy-product-launch-plan | Hosts the web app = F1 (free) for nonprod, P2v3 for prod |
| App Service | toylaunch{unique} | Web app with HTTPS enforced |

**Environment-aware SKU selection:**

| Environment | Storage SKU | App Service Plan SKU |
|-------------|------------|---------------------|
| nonprod | Standard_LRS | F1 (free tier) |
| prod | Standard_GRS | P2v3 (premium) |

## Tech stack

| Layer | Technology |
|-------|-----------|
| IaC | Bicep with modules |
| Automation | GitHub Actions |
| Authentication | OIDC (Federated Credentials) |
| Naming | uniqueString() function for globally unique resource names |

## How to run

> The "Run Workflow" button is only visible to me as the owner. To test this yourself, fork this repository and add your own `AZURE_CREDENTIALS` secret.

1. Go to the Actions tab
2. Select Deploy Lab 2 App Service
3. Click Run Workflow

The workflow deploys to `toy-app-rg` in `westus3` with `environmentType=nonprod` by default.

## Project links

- [Main template](./main.bicep)
- [App Service module](./modules/appService.bicep)
- [Workflow](../../.github/workflows/deploy-lab2.yaml)