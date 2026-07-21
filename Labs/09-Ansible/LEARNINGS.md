# Learnings

This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.

## Decisions i made and errors i ran into

I wanted to learn a bit more about ansible and its purpose, as far as i understood its similar to DSC in azure so setting the desired state of configuration but mostly for linux.

I.e ansible is used to install packages, managing users etc. So if terraform is used to build the "house" then ansible is kind of like furnishing the inside of the house itself.

My overall goal with this project was to automate everything i did in the lab before where i deployed linux VM, sshd into it and then created users, set file permissions, cron job etc just at a smaller scale for now.

What was interesting for me to find out is in the `inventory.ini` where you define VMs you work with and connection details, ansible can then ssh into those machines and do its work that you configured for it. Neat.


## Commands used

## Sources