# Lab 02 — Automated Resource Group Manager

Python script that manages the full lifecycle of an Azure Resource Group programmatically using the Azure SDK: Create, inspect and delete, all from the terminal with no portal interaction.

## What this does

Four sequential workflow steps, all executed in a single script run:

| Step | Function | Purpose |
|------|----------|---------|
| 1 | `list_resource_groups` | Lists all existing resource groups before doing anything |
| 2 | `create_resource_group_idempotent` | Creates `Python-Managed-RG` with mandatory tags: skips if already exists |
| 3 | `list_resources_in_rg` | Inventories resources inside the new RG (empty by design) |
| 4 | `delete_resource_group` | Deletes the RG and everything in it: cost control |

**Mandatory tags applied on creation:**

| Tag | Value |
|-----|-------|
| Environment | Lab |
| CostCenter | Automation |
| Owner | VirtualHermit |

## Tech stack

| Layer | Technology |
|-------|-----------|
| Language | Python 3 |
| SDK | Azure SDK for Python (azure-mgmt-resource, azure-identity) |
| Authentication | DefaultAzureCredential via `az login` |
| Design principle | Idempotency: Safe to run repeatedly without errors |

## How to run

1. Authenticate with Azure CLI:
```bash
   az login
   az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

2. Execute the script:
```bash
   python Labs/02-Resource-Group-Manager/resource_manager.py
```

3. The script will confirm the full lifecycle in terminal output: list existing RGs, create `Python-Managed-RG` with tags, inventory it, then delete it.

## Project links

- [Code](./resource_manager.py)