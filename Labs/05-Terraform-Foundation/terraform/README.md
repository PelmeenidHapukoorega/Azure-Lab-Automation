# Lab 05: Terraform Azure Foundation

Built a simple architecture that deploys a foundation for projects: 
a network, storage, and a VM ready to expand on. No portal UI.

## What this deploys

| Resource | Details |
|----------|---------|
| Resource Group | Container for all resources |
| Virtual Network | 10.0.0.0/16 with a single workload subnet (10.0.1.0/24) |
| Network Security Group | Allow SSH (100), Allow HTTP (200), Deny all inbound (4096) |
| Storage Account | Standard LRS, blob soft delete enabled, random suffix for global uniqueness |
| Network Interface | Private IP only; no public IP |
| Linux VM | Ubuntu 20.04 Gen 2, Standard_D2as_v6 |

## Design decisions

NSG rules allow SSH at priority 100 and HTTP at 200, with a deny-all 
inbound rule at 4096. Lower number = evaluated first, so legitimate 
traffic gets through and everything else gets blocked at the end.

Used a prefix variable for consistent naming across all resources. 
ST accounts require a globally unique name of at least 3 characters,
the prefix combined with a random suffix handles that automatically.

No public IP on the VM. Sits inside the VNet with a private IP only, 
which reduces the attack surface. If you need to reach it, you go through 
the network.

## What I learned

Learned to use resource references in Terraform: Instead of hardcoding 
values, each resource pulls properties from its parent directly. Same 
block-for-block logic I used in Bicep: write a block, plan, apply, 
verify, destroy, next block and repeat.

What surprised me was how readable Terraform is compared to what I 
expected. The plan command especially: Seeing exactly whats about to 
be deployed before touching anything real is genuinely useful for 
double checking work before it hits Azure.

Hit a Gen 1 vs Gen 2 image compatibility issue when deploying the VM. 
Standard_D2as_v6 is Gen 2 but the default Ubuntu 20.04 LTS image is 
Gen 1. Fixed by switching to the `20_04-lts-gen2` SKU. Less of a 
surprise, more of a reminder that you have to stay aware of these things 
as images and VM sizes keep moving forward.

## How to deploy

Prerequisites: Terraform >= 1.5.0, Azure CLI, authenticated via `az login`

```bash
git clone https://github.com/PelmeenidHapukoorega/Azure-Lab-Automation.git
cd Azure-Lab-Automation/Labs/05-Terraform-Foundation/terraform

# Create your tfvars: Never commit this
echo 'subscription_id = "your-subscription-id"' > terraform.tfvars

terraform init
terraform plan
terraform apply

# Tear down when done
terraform destroy
```
