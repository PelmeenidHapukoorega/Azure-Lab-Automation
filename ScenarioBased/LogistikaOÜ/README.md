# Scenario: Logistika OÜ — Cloud Infrastructure Modernisation

## Company background

Logistika OÜ is a mid-sized Estonian logistics company based in Tallinn with 180 employees. They operate a fleet of 60 delivery vehicles across Estonia and have partnerships with carriers in Latvia and Lithuania. Their annual revenue is approximately €8 million.

Currently they run everything on-premise — two physical servers in a server room at their Tallinn office, a Windows Server 2016 domain controller, a Linux server running their custom fleet tracking web application (PHP, MySQL), and a NAS for file storage. Their IT is managed by one person who is leaving in two months.

They were recently audited and received a non-compliance notice for GDPR — specifically around data retention, access logging, and backup practices. They have 90 days to remediate.

## Current problems

- Single point of failure — if either server goes down, operations stop
- No offsite backup — the NAS is in the same room as the servers
- No access logging — they cannot prove who accessed what data
- The fleet tracking app has no monitoring — they find out it's down when drivers call
- The IT person manages everything manually — no automation, no documentation
- VPN access to internal systems is via an old Cisco router that nobody knows how to configure anymore

## What they want

1. Fleet tracking application migrated to Azure and containerised if possible
2. All employee file storage moved to Azure
3. Proper backup with offsite retention
4. Access control — only the right people can access the right things
5. Remote management without needing to be on-site
6. Monitoring so they know about problems before drivers do
7. GDPR compliance remediated — audit logs, data retention policies, encryption at rest
8. A pipeline so future application updates don't require manual server access

## Constraints

- Budget: €800/month maximum
- GDPR remediation must be done within 90 days
- New IT person has basic Azure knowledge but no DevOps experience
- Fleet tracking app cannot be down for more than 2 hours during migration
- Data must remain within the EU
- Drivers use the tracking app on mobile — must be publicly accessible

# Architecture and decisions made

# Services list and cost estimate

# Architecture diagram

# Build log

# Incident response