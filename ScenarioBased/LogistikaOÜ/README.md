# Scenario: Cloud Infrastructure Modernisation

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

---

# Architecture and decisions made

After reading through the scenario, the first 3 main decision that came to mind were the following:

**Containerisation VS Lift and shift**

I noticed the brief explicitly stated that they wanted the app itself containerised if possible. The 2 decisions i cycled between at the start was lift and shift vs containerisation. I instinctively opted for containerisation over lift and shift because lift and shift would just replicate the same manual server management problem they already had, so that was instantly out of the questions and since i knew that azure has containerisation services like ACR, ACI, ACA and App service.

Eventually i opted to use ACR for storing and managing the container image and have the App service then run it.

ACR specifically is designed for storing and management of the containerized images, so all i needed was to write a dockerfile to instruct it how to install the fleet tracker app which then bakes the app and its dependencies all together, then i could push it to the ACR and have App service run it.

Now you may wonder why not use ACI or ACA over app service?

* ACI

With ACI the problem is that it has no pipeline integration, it restarts from scratch if it crashes which causes downtime. Mostly its purpose is for just one off tasks so basically quikcly have it run some minute task and done.

* ACA

Now with ACA we are dealing with fully managed, has built in autoscaling which is great when traffic should increase on the app and is good for microservices, but then again somewhat more complex and actually a bit expensive too on a smaller scale.

* App service

Also fully managed because its a PaaS offering, built in CI/CD integration for pushing updates to the app if needed and easier to operate since new IT person has basic azure knowledge that even he could handle it without say having the need to understand container orchestration or k8s.

So it all came down to operational simplicity at the end of the day, app service is easier to manage for the new person, no point in going over the top with complexity even if other options may have good benefits.

**GDPR remediation first**

Since the company was recently audited and found non compliant i figured GDPR compliance would need to be remediated first, why? First of all compliance always takes time and needs evidence it cant be an afterthought or built simultaneously because and this is key: It needs to inform every infrastructure decision from the start prior to implementing.

**Managed services over IaaS**

The current infrastructure is entirely manually managed by ONE person and he also had enough of the manual labor and decided to leave. The new person has basic knowledge of azure and no DevOps experience so its not looking good for him either. 

Picking managed services over IaaS in this scenario would reduce operational burden for the new guy, eliminate patching because with PaaS services the updates and patching is all managed by Azure and just makes it operable by someone without deep infrastructure knowledge.

4. Migration downtime

One of the key constraints is that the app cant have downtime more than 2 hours during migration. So some downtime was allowed but i started to think on how could i implement migration strategy in a way that there was no downtime at all?

Now i knew that building the container, pushing to ACR have App service pull and then run it would be smt like 30mins if even that. The risk came with MySQL database migration. Now it wasnt specified the size of data needed to migrate because AI didnt think about that. Lets assume i would copy data from the on prem MySQL to az database while the app is still running, now if i were to cut off during the process that would mean data could be lost when new entries are being made or files could get corrupted. 

So my approach to tackle that problem would be:

    1. Setup AZ database for MySQL empty and running
    2. Replicate data from the on prem MySQL to AZ MySQL using AZ Database Migration service which runs in the background while the old system is still functioning/live.
    3. Then i would point the App service to AZ MySQL, stop the old server. This is the only part where downtime would happen, but instead of hours of it, it would be minutes.
    4. Finally i would verify that migrated data is infact intact and drivers can connect and enter data.
    
---

# Services list and cost estimate

**App service B2 Linux, Basic tier**

Its stated that fleet tracking app is PHP/MySQL and App service supports PHP natively, fully managed, would scale automatically and removes the need for the Linux server entirely and is designed for web apps. Went with B2 sku as a reasonable starting point for stated 60 vehicles and 180 employees. Could later scale up based on monitoring data of the app. The upside is that no VM to manage.

Cost: €26.28/month

**Azure database for MySQL**

App service supported PHP natively for the app but not MySQL so i needed something for that, hence azure database for MySQL. This is the managed equal of their current installation. Chose Burstable tier over general purpose and memory optimized purely because the workload is not constant high cpu, drivers would just check in at the start or end of their day but not sit there constantly. Burstable skus generally accumulate credits when idle and spends them during bursts i.e when the driver would open the application so its kind of like the same analogy i used for ACI which was: do this and done. So same logic applies here: Burst when there is traffic.

For redundancy i went with ZRS for post migration availability, meaning that if AZ availability zone would go down the database would still stay up, given the 2 hour downtime constraint i wanted the database resilient to infrastructure failures after the migration too. Less headache for the company downstream.

Also i assume that 2 hour constraint applies ongoing, not just during the migration phase but also in production. If the database is down and recovery takes longer than 2 hours it would violate clients reqs.

Cost: €15.67/month

**Azure Files (Standard HDD, ZRS, 1TB)**

Opted for AZ files for replacint the on prem NAS for employee storage. Picked standard HDD over Premium SSD since workload is document storage and not high IOPS app data. 

Whats interesting to note with azure here is that at HDD is more expensive at lower storage capacity than SSD bit once it hits over 1TB it becomes 3x cheaper than SSD at the same capacity and the performance gain of SSD was unnecessary for opening and saving documents (at least thats what i assumed since again its not specified what kind of data we are dealing with here, in real environment it would need to be specified with the client).

1TB storage size here provides headroom for 180 employees assuming that 1 employee has around 1-2Gb in total then (quick maths) 2GB x 180 = ~360Gb. Meaning thats how much data would be migrated to Azure assuming my assumption would be correct and thus leaving plenty of headroom for a few years.

For redundancy again ZRS here, cant be losing employee files because GDPR. Not that GDPR here is the main reason, its just not good practice losing employee data for obvious reasons.

Cost: €70.17/month

**Azure backup for Azure Files (Daily 30, Weekly 2, Monthly 3, Yearly 1, ZRS, Cold tier)**

The backup was needed for azure files specifically to backup the migrated employee data and for evidence retention for GDPR reqs. AZ backup however doesnt support MySQL but no worries since Az database for MySQL has built in backup for it so no seperate backup needed. 

Chose Cold tier instead of hot or cool for the following reasons: 

Hot tier wasnt an option because it has high storage costs but the lowest access costs and use case is for frequently accessed or modified data whereas in this scenario we are dealing with data that is rarely accessed. 

Cold tier however is optimized for storing data that is rarely accessed but retrieval is fast but retrieval costs more. 

Since its not specified or i had no way of knowing how often the data would be accessed in reality i opted for cold tier instead because we are dealing with backup data and i mean how often do you really retrieve backup data? I mean i would think that if you need to access backup data frequently then something aint right.

So Cold tier in the long term, provided that backup data wouldnt be retrieved often would be the best choice in the long term but the trade off would be that if something does happen the retrieval would cost more but it could still be retrieved fast in critical situations.

**Private endpoints**

Needed 2 private endpoints for storage account and MySQL database.

Azure database MySQL cant be accessed without it if public traffic is disallowed. Now i could set it up with public endpoint however that would mean the database is reachable  from anywhere on the internet and someone COULD attempt to brute force either credentials, exploit vulnerabilities of if credentials would be leaked, attacker could then connect from anywhere.

So for security reasons and for better compliance (because we are dealing with employee and driver data) was a better option for both the database and file share.

Cost: ~€13/month for 2 endpoints ~€7/month for 1

Hourly: €0.009/per hour

**Azure container registry (Basic)**

Needed to store the containerised fleet trackers app Docker image or images. Basic tier was sufficient enough, 1 app, no geo replication was needed and registry is for storing and managing the images anyway so no employees would interact with it anyways.

Cost: €5.00/month

**Azure bastion (Excluded)**

I did consider azure bastion briefly because i saw Linux server which is running the app currently. However once i opted to use App service to host the app on instead the need for Bastion disappeared entirely. I considered it for remote access initially but its used for VM access and is expensive as hell, around 138€ a month. 

Remote management requirement is satisified by portal access from any browser at no cost.

**File Sync (Excluded)**

I didnt consider it for this project but i think its worth to mention if the client wanted to have a hybrid setup, but it doesnt fit here because that would still introduce manual management which contradicts the main goal.

**Log analytics workspace + Application insights**

2 issues that stood out from the reqs is that no access logging on their current infrastructure so no way of knowing who accessed what data and no monitoring for the app itself which was needed because currently when drivers were facing issues they would have to call someone in the company to let them know smt was wrong with the app.

Log analytics workspace is mandatory for any type of log collection which fit for the monitoring log collection and access logs. 

Now in order to get the logs from the app i decidet to add application insights for the app itself and direct it to send the logs to the workspace itself. Additionally with application insights i can create alerts when the app goes down before drivers could even call about the issue. 

Diagnostic settings on all resources send audit logs to Log analytics for GDPR evidence of access loggin therefore meeting compliance.

Best part? First 5gb/month per billing account is free. 

After the first month you would pay if you exceed the free tiers 5Gb, and since for now i had no way of knowing what the actualy data ingestion would look like, i want to set up cost alert for workspace itself, that way i would get notified if it approaches the 5GB threshold and analyze it better of what the actual costs would then look like. For now i assumed around 1,5-3gb per month.

Cost: €0/month

**Azure monitor alerts**

This is what would trigger the notification if something is wrong with the app i.e "knows about problems before drivers do" req which i briefly mentioned before.

For this scenario the main alerts i would need would be:

* Service health alerts to notify when azure itself has issues affecting the services, free

* Resource health alerts to notify when App service or MySQL go down, free

* Activity log alerts notifies on specific az operations like if someone deletes a resource, free

* Metric alerts were not needed here but it does cost money, around 10 cents per active time series. 

Actually in hindsight over in the vnet section i came to a realisation that since i have no way of actually knowing how much outbound data would be consumed i figured setting up the metric alert rule for app service using `data out` and set the threshold for 80gba month, which will then give the warning of nearing the threshold and then being able to better assess the actual cost of it.

Additonally i decided to add 4 metric rules before actually building:

    1. App service data out, which i already explained

    2. App service response time: If avg response time exceeds lets say 
    3-5 seconds, could be smt with the app or traffic.

    3. MySQL cpu: if consistently above 80% then might need to upsize the burstable tier.

    4. AZ files capacity alert at 800Gb used, warning before hitting the limit of 1TB.

So in total 4 metric alerts.

Cost: 4 x metric alerts at €0.10 per rule = €0.40/month

Overall its just useful, otherwise you hit limits on either one of them and you might overblow your budget or hit critical situations. 

* Budget alert (Optional)

Additionally to the metric alert rule, i figured i might as well set up budget alert for the overall solution so if the monthly cost estimate is around ~150 i could set the budget to say 200 and again better assess the actual cost of it all running.

* Log alerts, now this is optional to be honest, around 50 cents per rule however you could create query based alerts like if the app would return idk 500 errors more than 10 times for 5 minuts. But for now this was "luxury" option for this scenario, not exactly necessary.

Overall? Free at this scale

**Azure policy**

For enforcing compliance rules automatically i.e encryption at rest, audit logging required, resources deployed in EU region only. Not a one time fix but ongoing GDPR compliance evidence.

**Azure RBAC**

Controls access as in who can access what, only right people can manage right resources in other words granularity. Free and configured via Entra ID and AZ portal.

**Key vault**

Needed centralised management for any API keys the fleet tracking app would use, access logs on KV provide audit traile for credential access.

At this scale it would be cost negligible.

Cost: €0/month

**Github Actions (For CI/CD)**

Chose this over Azure devops because im used to it and Azure devops is mostly used internally in companies and here im operating alone. Equivalent CI/CD capability for this workload.

**Vnet with custom networking**

Needed for private endpoints and network isolation. Vnets are free on azure.

Traffic within the same vnet, so like in this scenario where there is app service to MySQL private endpoint which would all reside in the same region would be free.

What would cost money would be either outbound traffic to the internet or between azure regions, and in this case i would incur costs over outbound traffic since the app is publicly accessed (drivers use it on mobile on the road) except for the fact that First 100gb is free then around €0.07/GB after that. So as long as outbound data would stay within the 100gb you would pay nothing, and considering that app service was already set to stone with burstable i.e running when accessed i doubt it would cross the threshold.

However worth monitoring over a period of time to get a better estimate using metric alert rule. 

---

**Final cost estimate overall**

| Service | Monthly cost | Notes |
|---------|-------------|-------|
| App Service B2 | €26.28 | Can scale up if monitoring shows pressure |
| Azure Database for MySQL B1ms | €15.67 | Burstable, ZRS, includes built in backup |
| Azure Files 1TB Standard HDD ZRS | €70.17 | Employee file storage replacing NAS |
| Azure Backup (Azure Files) | €23.96 | Cold tier, Daily/Weekly/Monthly/Yearly retention |
| Azure Container Registry Basic | €5.00 | Stores fleet tracker container image |
| Private Endpoints x2 | ~€13.00 | MySQL and Azure Files, keeps data off public internet |
| Azure Monitor Metric Alerts x4 | €0.40 | Data out, response time, MySQL CPU, Files capacity |
| Azure Monitor Budget Alert | €0 | Free, set at €200/month |
| Log Analytics + Application Insights | €0 | Within 5GB free tier, estimated 1.5-3GB/month |
| Log Alerts | €0 | Excluded: optional luxury for this scenario |
| Outbound data transfer | €0 | Estimated within 100GB/month free tier, monitor via metric alert |
| Azure Policy | €0 | GDPR compliance enforcement |
| Key Vault | €0 | Secret management and audit trail |
| Azure RBAC | €0 | Access control |
| VNet + Subnets + NSGs | €0 | Network isolation for private endpoints |
| GitHub Actions | €0 | CI/CD pipeline |
| Azure Database Migration Service | €0* | One time use during migration only |
| **Total** | **~€154.48/month** | |

*Azure Database migration service has a free tier for offline migrations. One time cost during migration phase only, not ongoing.

**Budget headroom: ~€446/month** under the €600 target, ~€646/month under the €800 maximum. Provides room for scaling, custom domain SSL certificate, or additional services when needed.

> **Note:** This is a pre build estimate based on assumptions about data volumes, traffic and usage patterns. Actual costs will definetly vary. Monitor via Cost management/Cost analysis and the budget alert during the first 30 days to validate assumptions and adjust sizing where and when needed.

# Architecture diagram

![Architecture diagram](./architecture.png)

# Build log

**Updated as infra is being built**

Pinned provider `~> 4.0` to avoid silent breaking changes.

Added `use_azuread_auth = true` for backend so instead of storage account keys, EntraId auth would be used for state access which means no shared secrets. 

`prevent_deletion_if_contains_resources = false` on the RG for initial testing. Setting it to `true` once its ready to hit production. But as im developing this and testing each time running terraform block for block then setting it to `false` is just easier to manage. 

Used the same naming convention as in my previous project with `${var.prefix}-rg` which at this scale is fine, since single environment and single project however noted as scaling limitation if dev/prod split would ever be needed.

Now in this code i used my own tfstate container on azure but if it was to be a real project you would create your own tf.state storage account and container to house terraform state so it could check against your current environment on Azure, but in this case since its fictional i was using mine because setting up another subscription to simulate real conditions would add extra time to set up properly.

And to top it all off, using personal subscription for clients state would add access control issues, billing and continuity risks  which would be outside the clients control and we dont want that.

Initial resource list was missing Private DNS zones and without them the endpoints would get a private IP sure but DNS resolution for the resources public FQDN would still resolves publicly by default which would defeat the purpose of the endpoints all together.

I needed 2 private DNS zones per service, so:

* `privatelink.mysql.database.azure.com` for MySQL
* `privatelink.file.core.windows.net` for storage.

Sized the Vnet as `10.1.0.0/24` giving it room for both subnets + headroom for future ones if needed. App service at `/27` above the documented `/28` min for Vnet integration to specifically leave room in case of scaling the plan to more instances. PEs at `/28` which would cover the 2 PEs with room for more later (Key vault).

Split subnets between the App service and private endpoints, purely for delegation reason when it came to App service itself, why? I wanted the subnet to act as a gateway for the App service so that outbound traffic would route into the VNet and then reach things like MySQLs private endpoint. 

Delegated it exclusively to App serice via `Microsoft.Web/serverFarms` so nothing else could be deployed into that same subnet.

Then i added `subnets/action` to service delegation which would permit Appservice to provision its NIC in the subnet and giving it an actual address inside the Vnet so traffic could reach the PE instead of appearing to come from outside of it. 

Now PEs are configured to only accept connections that come from inside the VNet so without the NIC on the Appservice it would hit the PE from outside and get rejected because it wouldnt have any idea tha the traffic in this case would be the app.

Did the first terraform init/plan and deploy to verify resources would deploy with set configurations before moving on. All good.

Moved onto adding NSG resource, why NSG at all? Well for 1 to reuse existing pattern from my other projects and 2ndly for second layer defense and specifically for PE subnet since both PEs are handling sensitive data: App data in MySQL and Employee files in Azure files.

No NSG on appservice since subnet is self limiting by design.

The 2 NSG rules allow inbound traffic for both the DB and file shares and i scoped them respectively:

Set the source destination for app service itself since thats where the inbound traffic would come from to both PEs and from PEs would move forward respectively to DB and file shares.

By scoping the destination itself narrowly instead of leaving it on `"*"` (wildcard) meant the rules would only ever match traffic headed into exclusively to PE subnet. Aka least privilege logic.

Noticed i had `source_address_prefix` and `destination_address_prefix` swapped accidentally and if i wouldnt have clocked it i would have just allowed PE subnet traffic to PE subnet...

TDLR: No valid path to reach Az files since rule matching traffic pattern didnt exist.

Minor mistake but i think its still noteworthy, what caught it was when i was comparing rule sets for both MySQL and Files and noticed they werent consistent so i double checked both to make sure.

Added subnets NSG association resource to main.tf and forgot about referencing PE subnets id.

Without it, it wouldnt have any idea what subnet should be associated with the NSG and its rule sets.

After running plan and deploy again i checked for NSG rules themselves and then seperately checked that the NSG was only associated with the PE subnet and not with Appservice subnet as per design.

Added private DNS zones for both the database and file share because otherwise DNS would resolve publicly even tho access would still depend on whether the resources have `public network access` disabled or enabled and even then it wouldnt resolve to the public IP because MySQL accepts private endpoint traffic only. 

In other words, without private zones the fleet tracker app couldnt reach its own database. 

ran plan again then verified that both zones now existed with VNet links and auto registration disabled.

# Incident response