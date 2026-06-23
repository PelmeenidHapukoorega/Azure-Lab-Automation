# Documentation without hands-on will get you nowhere!

I wanted to try my hand at deploying actual infra by taking my previously done labs and using my lab notes from AZ 305.
Not gonna lie, did not expect what i walked in on, but in the best way possible!

I did say in AZ 305 readme that i meant it when i said im genuinely pursuing to become Solutions architect, and I will.

I mean sure it can be frustrating, lots of trial and error, running into walls, switching regions, deployment failures, switching SKUs, forgetting passwords...HOWEVER!
The satisfaction of finally seeing that green checkmark after so many trials and errors is... satisfying to say the least haha.

Anyway, below i have listed my automation and deployment projects, enjoy!




# Azure Lab Automation

This repository contains my Infrastructure as Code (IaC) and CI/CD pipelines for Azure learning projects.

## Table of Contents

* [Lab 01: Automated Nginx Deployment](#lab-01-automated-nginx-deployment)
* [Lab 02: Automated Resource Group Manager](#lab-02-automated-resource-group-manager)
* [Lab 05: Terraform Azure Foundation](#lab-05-terraform-azure-foundation)

---

## Lab 01: Automated Nginx Deployment

**Goal:** Deploy a Linux Web Server automatically without using the Portal.

**Tech Stack**
- **Language:** Bicep (Infrastructure as Code)
- **Automation:** GitHub Actions
- **Security:** OIDC (Federated Credentials) — no stored passwords

**Features**
- Automated region selection
- Bootstrapping (auto install Nginx on startup)
- Dynamic Resource Group management

**How to Run**

> The "Run Workflow" button is only visible to me as the owner. To test this yourself, fork this repository and add your own `AZURE_CREDENTIALS` secret.

1. Go to the Actions tab
2. Select Deploy Lab 01
3. Click Run Workflow and choose your target region

[Code](Labs/01-Nginx-Server/main.bicep)

---

## Lab 02: Automated Resource Group Manager

**Goal:** Deploy a core Azure Resource Group programmatically using the Azure SDK for Python, ensuring cost accountability and governance through mandatory tagging.

**Tech Stack**
- **Language:** Python 3 (Azure SDK)
- **Authentication:** Default Azure credentials via `az login`
- **Design principle:** Idempotency — the script can run repeatedly without errors

**Features**
- Idempotent creation: checks if the Resource Group exists before creating it
- Mandatory tagging: enforces `Environment`, `CostCenter`, and `Owner` tags on creation
- Automated cleanup: deletes the Resource Group after creation to prevent accidental charges

**How to Run**

1. Authenticate with Azure CLI:
```bash
   az login
   az account set --subscription "YOUR-SUBSCRIPTION-ID"
```
2. Execute the script:
```bash
   python Labs/02-Resource-Group-Manager/resource_manager.py
```
3. The script will confirm the full lifecycle in terminal output: list existing RGs, create `Python-Managed-RG` with tags, then delete it.

[Code](Labs/02-Resource-Group-Manager/resource_manager.py)

---

## Lab 05: Terraform Azure Foundation

**Goal:** Deploy a complete Azure infrastructure foundation using Terraform — VNet, NSG, Storage Account, and VM. No portal clicks.

**Tech Stack**
- **IaC:** Terraform (HCL)
- **Provider:** azurerm ~> 4.0
- **Authentication:** Azure CLI

**How to Run**

1. Navigate to the terraform folder:
```bash
   cd Labs/05-Terraform-Foundation/terraform
```
2. Create your `terraform.tfvars` (never commit this): subscription_id = "your-subscription-id"
3. Deploy:
```bash
   terraform init
   terraform plan
   terraform apply
```
4. Tear down when done:
```bash
   terraform destroy
```

[README](Labs/05-Terraform-Foundation/README.md) | [Code](Labs/05-Terraform-Foundation/terraform/)
