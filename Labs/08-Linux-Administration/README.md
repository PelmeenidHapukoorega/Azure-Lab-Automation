# Lab 08: Linux Administration

Hands-on Linux administration on an Azure VM deployed with Terraform. No new cloud services — just getting comfortable operating Linux itself as the foundation for everything that comes next (Ansible, Grafana, etc).

## What this covers

- Filesystem structure and navigation
- User management and file permissions
- Service management with systemd
- Log inspection with journalctl
- Bash scripting and output redirection
- Cron jobs for task automation
- Package installation and nginx configuration
- System resource monitoring (top, df, free)

## Infrastructure

Linux VM deployed with Terraform using the reusable networking module from [Deployment-templates](https://github.com/PelmeenidHapukoorega/Deployment-templates). Azure Monitor Agent extension installed for telemetry.

## Notes

All commands used, key learnings, and source references are documented in [LEARNINGS.md](./LEARNINGS.md).