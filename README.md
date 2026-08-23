# Theory wont get you anywhere without practice

This repo is my path into Azure and DevOps engineering. Labs, a full scenario infra build (currently ongoing) and whatever comes after, all built while i was studying for AZ-104 and now AZ-400.

Didnt start with some grand plan tbh. Mostly just wanted to see if i could actually deploy real infra and not only read about it. Turns out that was exactly the thing i was missing, the trial and error, failed deployments, staying up until morning for debugging sessions, chasing a lock nobodys doc could explain, all of it is genuinely the shit i enjoy doing.

Current flagship here is Logistika OÜ, full scenario based Azure migration for fictional logistics company. Private networking, identity based security with 0 static credendtials anywhere, GDPR driven compliance and audit logging, full monitoring and alerting layer and a working CI/CD pipeline using OIDC federation for best practice.

Every decision, every bug, every fix documented as it happened, wrong turns and "stupid" mistakes included because i genuinely believe thats the part that actually would show how i think and not just what i can deploy.

* Update July 2026: Repo has grown quite a bit since i first started. See the labs below for where things have ended up so far.

# Azure Lab Automation

This repository contains my Infrastructure as Code (IaC) and CI/CD pipelines for Azure learning projects as well as other projects.

## Table of Contents

### Foundation Labs section

1. [Automated Nginx Deployment](#lab-01-automated-nginx-deployment)
2. [Automated Resource Group Manager](#lab-02-automated-resource-group-manager)
3. [App Service Deployment](#lab-03-app-service-deployment)
4. [Multi-Region Database Deployment](#lab-04-multi-region-database-deployment)
5. [Terraform Azure Foundation](#lab-05-terraform-azure-foundation)
6. [AKS Flask App](#lab-06-aks-flask-app)
7. [Security Pipeline](#lab-07-security-pipeline)
8. [Linux Administration](#lab-08-linux-administration)
9. [Ansible](#lab-09-ansible)
10. [Grafana](#lab-10-grafana)
11. [Kubernetes Networking](#lab-11-kubernetes-networking)
---

### Scenario based projects

1. [LogistikaOÜ: Cloud Infrastructure Modernisation](#logistikaoü-cloud-infrastructure-modernisation)

## Lab 01: Automated Nginx Deployment

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

[README](Labs/01-Nginx-Server/README.md) | [Code](Labs/01-Nginx-Server/main.bicep)

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

[README](Labs/02-Resource-Group-Manager/README.md) | [Code](Labs/02-Resource-Group-Manager/resource_manager.py)

---

## Lab 03: App Service Deployment

**Goal:** Deploy an Azure App Service environment using Bicep modules with environment-aware configuration.

**Tech Stack**
- **Language:** Bicep with modules
- **Automation:** GitHub Actions
- **Security:** OIDC (Federated Credentials)

**Features**
- Modular Bicep structure — App Service logic separated into a reusable module
- Environment-aware SKU selection — free tier for nonprod, premium for prod
- Globally unique resource naming via `uniqueString()`

**How to Run**

> To test this yourself, fork this repository and add your own `AZURE_CREDENTIALS` secret.

1. Go to the Actions tab
2. Select Deploy Lab 2 - App Service
3. Click Run Workflow

[README](Labs/03-AppService/README.md) | [Code](Labs/03-AppService/main.bicep)

---

## Lab 04: Multi-Region Database Deployment

**Goal:** Deploy Azure SQL databases and virtual networks across three regions simultaneously using Bicep loops.

**Tech Stack**
- **Language:** Bicep with modules and loops
- **Automation:** GitHub Actions
- **Security:** OIDC (Federated Credentials)

**Features**
- Single template deploys to West Europe, East US 2, and East Asia in one run
- Bicep `for` loops for multi-region iteration
- Production-only SQL auditing with dedicated storage account

**How to Run**

> To test this yourself, fork this repository and add your own `AZURE_CREDENTIALS`, `SQL_ADMIN_LOGIN`, and `SQL_PASSWORD` secrets.

1. Go to the Actions tab
2. Select Deploy Lab 3 - Database
3. Click Run Workflow

[README](Labs/04-Database/README.md) | [Code](Labs/04-Database/database.bicep)

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
2. Create your `terraform.tfvars` (never commit this): `subscription_id = "your-subscription-id"`
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

---

## Lab 06: AKS Flask App

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

---

## Lab 07: Security Pipeline

**Goal:** Demonstrate infrastructure security scanning as a pipeline gate — bad code never reaches Azure.

**Tech Stack**
- Terraform
- Checkov (IaC security scanner)
- GitHub Actions
- Reusable networking module from [Deployment-templates](https://github.com/PelmeenidHapukoorega/Deployment-templates)

**Highlights**
- Checkov scans Terraform before any deployment runs
- Deliberate SSH violation (`0.0.0.0/0` on port 22) blocks the pipeline via `CKV_AZURE_10`
- Fix the violation, push again — pipeline goes green and VM deploys
- Suppressed findings documented with inline `#checkov:skip` comments and reasons

[README](Labs/07-Security-Pipeline/README.md) | [Code](Labs/07-Security-Pipeline/)

---

## Lab 08: Linux Administration

**Goal:** Hands on Linux administration as the foundation for Ansible and configuration management.

**Tech Stack**
- Terraform (VM provisioning)
- Ubuntu 22.04 LTS
- nginx, systemd, cron, Bash

**Highlights**
- User management, file permissions, service lifecycle
- Bash scripting with cron automation
- nginx installation and configuration
- Azure Monitor Agent extension deployed via Terraform

[README](Labs/08-Linux-Administration/README.md) | [Code](Labs/08-Linux-Administration/)

---

## Lab 09: Ansible

**Goal:** Automate everything done manually in Lab 08 using Ansible — one command configures a fresh VM completely.

**Tech Stack**
- Terraform (VM provisioning)
- Ansible (configuration management)
- Ubuntu 22.04 LTS

**Highlights**
- Single playbook installs nginx, creates users, sets permissions, deploys scripts and cron jobs
- SSH hardening: root login disabled, fail2ban configured to block after 3 failed attempts
- Ansible runs from WSL over SSH, no agent required on the target VM
- Demonstrates the handoff between Terraform (provision) and Ansible (configure)

[README](Labs/09-Ansible/README.md) | [Code](Labs/09-Ansible/)

---

## Lab 10: Grafana

**Goal:** Deploy Azure Managed Grafana and connect it to Lab 06's Log Analytics workspace to visualize real AKS metrics.

**Tech Stack**
- Terraform
- Azure Managed Grafana
- Azure Monitor
- System-assigned managed identity

**Highlights**
- Grafana deployed and configured entirely with Terraform
- System-assigned identity authenticates to Azure Monitor automatically
- Monitoring Reader scoped to subscription so Grafana can discover all resources
- Real AKS metrics visualized in a live dashboard

[README](Labs/10-Grafana/README.md) | [Code](Labs/10-Grafana/)

---

## Lab 11: Kubernetes Networking

**Goal:** Understand Kubernetes internal networking by deploying a two-service application and proving inter-service DNS resolution works inside the cluster.

**Tech Stack**
- Terraform
- AKS (Azure Kubernetes Service)
- Azure Container Registry
- Flask (backend), nginx (frontend)
- Kubernetes Deployments and Services

**Highlights**
- Frontend pod calls backend via Kubernetes internal DNS (`backend-service:5000`) — confirmed working with `kubectl exec`
- Discovered custom NSGs break AKS internal traffic — had to remove networking module and let AKS manage its own networking
- Kubelet identity changes on every cluster recreate — ACR pull role must be updated each time
- Internal DNS only resolves inside the cluster — browser cannot resolve Kubernetes service names

[README](Labs/11-Kubernetes-Networking/README.md) | [Code](Labs/11-Kubernetes-Networking/)

## LogistikaOÜ: Cloud Infrastructure Modernisation

**Goal:** Full scenario-based Azure migration for a fictional mid-sized logistics company — GDPR-driven infrastructure design, identity-based security with zero static credentials, complete monitoring and compliance layer, and a working CI/CD pipeline validated end-to-end with a real application.

**Scenario:** on-premise infrastructure with no offsite backup, no access logging, no monitoring, and a GDPR non-compliance notice with a 90-day remediation deadline. Full case study, architecture decisions, and cost estimates in the project README.

**Tech Stack**
- Terraform (HCL), azurerm ~> 4.0
- Azure networking: VNet, delegated subnets, NSGs, private endpoints, private DNS zones
- Azure Database for MySQL Flexible Server, Azure Files, Key Vault, Recovery Services Vault
- Azure Policy (Allowed Locations, tag inheritance via Modify effect), diagnostic settings for audit logging
- Azure Monitor: metric alerts, budget alert, KQL-based scheduled query alert
- GitHub Actions with OIDC federated identity, no stored secrets
- Docker, PHP, MySQL (minimal test application)
- Application Insights, custom telemetry via REST API

**Highlights**
- Fully identity-based access throughout — managed identities for ACR, Key Vault, GitHub Actions, and tag inheritance, no static credentials anywhere in the stack
- GDPR compliance mapped directly to infrastructure: Azure Policy enforcement, audit logging across Key Vault/Storage/MySQL, encryption at rest documented as a platform default
- Real, working CI/CD pipeline using OIDC federation — builds and pushes a Docker image with no secrets stored in GitHub
- Minimal test application (PHP/MySQL) deployed and verified end-to-end: TLS-verified database connection, real data writes/reads, genuine telemetry reaching Application Insights via REST API
- Full build log documenting every architectural decision, bug, and fix as it happened — including a multi-session debugging saga around Azure Backup's implicit locks and a Git Bash path-mangling bug
- Cost estimate reconciled against as-built reality, with corrections documented where initial assumptions were wrong

[README](ScenarioBased/LogistikaOÜ/README.md) | [Code](ScenarioBased/LogistikaOÜ/terraform/) | [References](ScenarioBased/LogistikaOÜ/REFERENCES.md) | [Runbook](ScenarioBased/LogistikaOÜ/RUNBOOK.md)