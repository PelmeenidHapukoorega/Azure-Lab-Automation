# Theory wont get you anywhere without practice

I wanted to try my hand at deploying actual infra by taking my previously done labs and using my lab notes from my other repo as well as my experience in studying for AZ-104.
Not gonna lie, did not expect what i walked in on, but in the best way possible.

I mean sure it can be frustrating, lots of trial and error, running into walls, switching regions, deployment failures, switching SKUs, forgetting passwords, endless terraform/bicep reading...HOWEVER!
The satisfaction of finally seeing all the puzzle pieces together and making that final deployment is amazing.

Anyway, below i have listed my automation and deployment projects as portfolio.


# Azure Lab Automation

This repository contains my Infrastructure as Code (IaC) and CI/CD pipelines for Azure learning projects as well as other projects.

## Table of Contents

* [Automated Nginx Deployment](#lab-01-automated-nginx-deployment)
* [Automated Resource Group Manager](#lab-02-automated-resource-group-manager)
* [App Service Deployment](#lab-03-app-service-deployment)
* [Multi-Region Database Deployment](#lab-04-multi-region-database-deployment)
* [Terraform Azure Foundation](#lab-05-terraform-azure-foundation)
* [AKS Flask App](#aks-flask-app)
---

## Project: Automated Nginx Deployment

**Goal:** Deploy a Linux Web Server automatically without using the Portal.

**Tech Stack**
- **Language:** Bicep (Infrastructure as Code)
- **Automation:** GitHub Actions
- **Security:** OIDC (Federated Credentials); no stored passwords

**Features**
- Automated region selection
- Bootstrapping (auto install Nginx on startup)
- Dynamic Resource Group management

**How to Run**

> To test this yourself, fork this repository and add your own `AZURE_CREDENTIALS` secret.

1. Go to the Actions tab
2. Select Deploy Lab 01
3. Click Run Workflow and choose your target region

[Code](Labs/01-Nginx-Server/main.bicep)

---

## Project: Automated Resource Group Manager

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

## Project: Terraform Azure Foundation

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

[README](Labs/05-Terraform-Foundation/terraform/README.md) | [Code](Labs/05-Terraform-Foundation/terraform/)

## AKS Flask App

**Goal:** Deploy a containerised Flask app to Azure Kubernetes Service, expose it publicly via Application Gateway, and demonstrate live autoscaling under load.

**Tech Stack**
- Python Flask, Docker
- Azure Kubernetes Service (AKS)
- Terraform (IaC)
- GitHub Actions (CI/CD)
- Azure Monitor, Log Analytics, Key Vault

**Highlights**
- Horizontal Pod Autoscaler scales from 2 to 10 pods under load, visible live in the UI
- Three separate GitHub Actions workflows: deploy infrastructure, deploy app, destroy everything
- Full RBAC setup across Azure and Kubernetes

[README](Labs/06-AKS-Flask-App/README.md) | [Code](Labs/06-AKS-Flask-App/)
