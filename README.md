# Documentation without hands on will get you nowhere!

I wanted to try my hand at deploying actual infra by taking my previously done labs and using my lab notes from AZ 305.
Not gonna lie, did not expect what i walked in on, but in the best way possible!

I did say in AZ 305 readme that i meant it when i said im genuinely pursuing to become Solutions architect, and I will.

I mean sure it can be frustrating, lots of trial and error, running into walls, switching regions, deployment failures, switching SKUs, forgetting passwords...HOWEVER!
The satisfaction of finally seeing that green checkmark after so many trials and errors is... satisfying to say the least haha.

Anyway, below i have listed my automation and deployment projects, enjoy!




## Azure Lab Automation

This repository contains my Infrastructure as Code (IaC) and CI/CD pipelines for Azure learning projects.

## Table of contents
* [Project 01: Automated Nginx Deployment](#project-01-automated-nginx-deployment)
* [Project 02: Automated Resource Group Manager](#project-02-automated-resource-group-manager)
* [Project 03: Automated VM Scheduler](#project-03-automated-vm-scheduler)
  
## Project 01: Automated Nginx Deployment 
**Goal:** Deploy a Linux Web Server automatically without using the Portal.

### Tech Stack
*   **Language:** Bicep (Infrastructure as Code)
*   **Automation:** GitHub Actions
*   **Security:** OIDC (Federated Credentials) No stored passwords.
*   **Features:**
    *   Automated Region Selection 
    *   Bootstrapping (Auto install Nginx on startup)
    *   Dynamic Resource Group management

### How to Run
(Note: The "Run Workflow" button is only visible to me since im the owner. To test this yourself, please **Fork** this repository and add your own `AZURE_CREDENTIALS` secret.)

1. Go to the Actions tab.
2. Select Deploy Lab 01.
3. Click Run Workflow and choose your target region.


## Project 02: Automated Resource Group Manager
**Goal:** Deploy a core Azure Resource Group (RG) programmatically using the Azure SDK for Python, ensuring Cost Accountability and Governance through mandatory tagging.

### Tech Stack
*   **Language:** Python 3 for orchestration and execution logic (Azure SDK).
*   **Authentication:** Default Azure credentials, az login as token.
*   **Design principle:** Idempotency, ensures the script can run repeateadly without errors.
*   **Governance:** Mandatory Tagging, enforces essential tags for Cost Control and Auditing.
*   **Features:**
    *   Idempotent Creation: Checks if the Resource Group exists before creating it, guaranteeing predictable deployment. 
    *   Cost Control Tags: Automatically applies mandatory tags ('Environment: Lab', 'CostCenter: Automation', 'Owner: VirtualHermit') during creation.
    *   Automated clean up: Includes a crucial final step ('begin_delete') to delete the Resource Group ('Python-Managed-RG'), preventing accidental Azure charges.

### How to Run

1. Authenticate Locally: Ensure you have logged into the Azure CLI and set your target subscription.
   `az login`
   `az account set --subscription "YOUR-SUBSCRIPTION-ID"`
2. Execute the script: From the root of your repository, execute the Python file using its relative path.
   Example: `python Labs/02-Resource-Group-Manager/resource_manager.py`
3. Verify: The script will confirm the full lifecycle in the terminal output: Listing existing RGs, creating the new `Python-Managed-RG` with tags, and finally deleting it completely (for cost control).
