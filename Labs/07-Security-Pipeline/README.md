# Lab 07: Security Pipeline

A Terraform-deployed Linux VM with a GitHub Actions pipeline that runs Checkov security scanning before any infrastructure is provisioned. If Checkov finds violations, the deploy is blocked. Fix the code, push again, pipeline goes green and deploys.

Built to demonstrate that security gates belong in the pipeline itself, not as an afterthought after deployment.

## Demo

https://youtu.be/VypXE0ihoI8

## What this deploys

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | lab7-rg | Container for all resources |
| Virtual Network | lab7-vnet | Private network via networking module |
| Subnet | default (10.0.1.0/24) | VM subnet |
| NSG | lab7-nsg | Network security group with deny-all default |
| Public IP | lab7-pip | Static public IP for SSH access |
| NIC | lab7-nic | Connects VM to subnet and public IP |
| Linux VM | lab7-vm | Ubuntu 22.04 LTS Gen2, Standard_D2as_v6 |

## Tech stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform |
| Security scanning | Checkov |
| CI/CD | GitHub Actions |
| Networking | Reusable module from [Deployment-templates](https://github.com/PelmeenidHapukoorega/Deployment-templates) |
| State management | Remote state in Azure Blob Storage with Azure AD auth |
| OS | Ubuntu 22.04 LTS Gen2 |

## How the pipeline works

Two jobs, sequenced deliberately:

**Job 1: security-scan**
Runs Checkov against the Terraform code. `soft_fail: false` means any violation causes the job to fail with a non-zero exit code.

**Job 2: deploy**
Only runs if `security-scan` passes (`needs: security-scan`). Runs `terraform init` and `terraform apply -auto-approve`.

If Checkov finds a violation — the deploy job never starts. Fix the code, push again, both jobs run in sequence and the VM gets deployed.

**The demo:**
The deliberate violation was an NSG rule opening SSH (port 22) to `0.0.0.0/0` — a real, common misconfiguration. Checkov caught it via `CKV_AZURE_9`. Removing the rule and pushing again produced a clean scan and a successful deploy.

## Checkov findings

| Check | Finding | Resolution |
|-------|---------|------------|
| CKV_AZURE_9 | SSH open to 0.0.0.0/0 | **Deliberate violation** — removed the open NSG rule to demo the gate |
| CKV_AZURE_119 | NIC uses a public IP | Suppressed — public IP required for SSH demo access |
| CKV_AZURE_50 | No VM monitoring agent | Suppressed — not relevant to this project's scope |
| CKV_TF_1 | Module source not pinned to commit hash | Fixed — pinned to commit SHA `9733a99` |
| CKV_TF_2 | Module source not pinned to version tag | Fixed — same fix as CKV_TF_1 |

Suppressed findings use inline `#checkov:skip` comments with documented reasons directly in the code.

## What I learned

The pipeline itself was straightforward to write. The interesting parts were everything that broke before it worked.

**Terraform state and Azure AD auth** — `sandertfstate` had `allowSharedKeyAccess` disabled from earlier security hardening. The pipeline was using `ARM_ACCESS_KEY` which got blocked. Switched to `use_azuread_auth = true` in the backend block, service principal already had the right permissions from Lab 06.

**Variable naming matters exactly** — `TF_VAR_ssh_publickey` is not the same as `TF_VAR_ssh_public_key`. Terraform was silently waiting for manual input instead of throwing an obvious error, which made it look like a state lock issue when it wasn't.

**State blob leases** — when a pipeline run gets killed mid-apply, it can leave an infinite lease on the state blob. `terraform force-unlock` and `az storage blob lease break` are the tools for this, though they don't always cooperate cleanly. Sometimes waiting for the lease to expire naturally is the only option.

**Checkov finds more than you expect** — it flagged the module source not being pinned to a commit hash, which was something we'd already discussed as a tradeoff. Turns out it's a real, documented check (`CKV_TF_1` and `CKV_TF_2`). Fixed it properly rather than suppressing it.

## How to run

**Required GitHub secrets:**

| Secret | Value |
|--------|-------|
| `AZURE_CREDENTIALS` | Service principal JSON |
| `AZURE_SUBSCRIPTION_ID` | Your subscription ID |
| `SSH_PUBLIC_KEY` | Your SSH public key (`cat ~/.ssh/id_rsa.pub`) |

**To demo the security gate (red → green):**

1. Add the open SSH rule back to `main.tf` and push — pipeline fails at security-scan
2. Remove it and push again — pipeline passes and deploys the VM

**To deploy manually:**
```bash
cd Labs/07-Security-Pipeline/terraform
terraform init
terraform apply
```

**To destroy:**
```bash
terraform destroy
```
