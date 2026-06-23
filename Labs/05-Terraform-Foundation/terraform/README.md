Built a simple architecture that deploys a simple foundation for projects.

VM, ST account, VNet with a subnet, no public IP, created a NIC and set up NSG rules

I added NSG rules to allow SSH traffic at priority 100 then allowed HTTP traffic at 200 and blocked and denied all inbound at 4096 for security of the VM. Used Prefix variable for easier naming of things, especially due to ST account which requires at least 6-12 characters.

Learned to use references on terraform and applied same logic in writing it as i did in Bicep which is block for block > Deploy > verify > destroy > next block > repeat. What surprised me so far was that terraform is relatively easy to write, really liked the plan option of it which then showed me what changes were made and what was about to be deployed, which is great when double checking deployments. Next was image having gen1 and not being able to deploy the VM because of it, it didnt necessarily surprise me, it was more as affirmation how you have to be aware of these things since everything is constantly being updated and moved forward.
