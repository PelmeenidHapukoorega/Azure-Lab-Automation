# Documentation without hands on will get you nowhere!

I wanted to try my hand at deploying actual infra by taking my previously done labs and using my lab notes from AZ 305.
Not gonna lie, did not expect what i walked in on, but in the best way possible!

I did say in AZ 305 readme that i meant it when i said im genuinely pursuing to become Solutions architect, and I will.

I mean sure it can be frustrating, lots of trial and error, running into walls, switching regions, deployment failures, switching SKUs, forgetting passwords...HOWEVER!
The satisfaction of finally seeing that green checkmark after so many trials and errors is... satisfying to say the least haha.

Anyway, below i have listed my automation and deployment projects, enjoy!




## Azure Lab Automation

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
