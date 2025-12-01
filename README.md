# Azure Lab Automation

This repository contains my Infrastructure as Code (IaC) and CI/CD pipelines for Azure learning projects.

## Project 01: Automated Nginx Deployment ("MinuVirtukas")
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
1.  Go to the **Actions** tab.
2.  Select **Deploy Lab 01**.
3.  Click **Run Workflow** and choose your target region.
