# Lab 09: Ansible

Ansible playbook that automates everything done manually in Lab 08. Fresh VM, one command, fully configured server.

## Demo

<!-- Demo video coming soon -->

## What the playbook does

- Installs nginx and fail2ban
- Deploys a custom nginx page
- Creates `ansibleuser` with sudo access and correct home directory permissions
- Deploys `sysinfo.sh` script with a cron job running every 5 minutes
- Ensures nginx and SSH are enabled and running
- Disables root SSH login
- Configures fail2ban to block IPs after 3 failed SSH attempts

## Tech stack

| Layer | Technology |
|-------|-----------|
| Infrastructure | Terraform |
| Configuration management | Ansible |
| Target OS | Ubuntu 22.04 LTS |
| Security | fail2ban, SSH hardening |

## How to run

**Deploy the VM:**
```bash
cd terraform
terraform init
terraform apply
```

**Add the VM IP to inventory**

Example: Labs/09-Ansible/ansible/inventory.ini

**Run the playbook from WSL:**
```bash
cd ansible
ansible-playbook playbook.yml -i inventory.ini
```

**Destroy when done:**
```bash
cd terraform
terraform destroy
```

## Notes

All syntax learnings, errors hit, and decisions made are documented in [LEARNINGS.md](./LEARNINGS.md).