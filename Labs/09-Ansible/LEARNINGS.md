# Learnings

This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.

## Decisions i made and errors i ran into

I wanted to learn a bit more about ansible and its purpose, as far as i understood its similar to DSC in azure so setting the desired state of configuration but mostly for linux.

I.e ansible is used to install packages, managing users etc. So if terraform is used to build the "house" then ansible is kind of like furnishing the inside of the house itself.

My overall goal with this project was to automate everything i did in the lab before where i deployed linux VM, sshd into it and then created users, set file permissions, cron job etc just at a smaller scale for now.

What was interesting for me to find out is in the `inventory.ini` where you define VMs you work with and connection details, ansible can then ssh into those machines and do its work that you configured for it. Neat.

I reused the same resources from the previous lab to save time, ran init before applying. Always init before apply, since it needs to download the set providers, download the networking module i created earlier and connect to remote state in my st account on azure `sandertfstate`.

Forgot to create tfvars file where you define subscription id and ssh public key, so after running plan i was asked to enter ssh public key manually. Added tfvars and added both.

* Reminder to self: Never commit tfvars for security reason, otherwise the file will be visible along with all sensitive information that could be used to impersonate yourself. For example lets say i would commit my tfvars where the subscription ID sits, it can then be combined with other information which could then help someone target my account.

SSH public key here is irrelevant because its public (clue is in the name)

After running init, plan and apply and confirmed the VM was up, i then added my vm ip to ansible in order for ansible understand where to connect to, which user to use and what SSH key to authenticate with.

Added `inventory.ini` to .gitignore at repos root because i wanted git to ignore it since it contained vms IP. Its just good practice, can never be too safe.

Next i needed to install ansible and i could see 2 ways to approach this:

Option 1: Install ubuntu on WSL through pwsh and then install ansible inside it

Or

Option 2: Run ansible from the VM itself and run it locally against itself.

Decided to go with option 1 because its more realistic when it comes to production set up where ansible would be run from local machine or through CI/CD pipeline, and since im studying for az-400 and want to understand the DevOps side of things, it felt like the logical choice.

Ran `wsl --install -d Ubuntu` on my pc in powershell and downloaded ubuntu and then once installed and logged i proceeded to install ansible.

Once ansible was installed and i had verified it, i needed copy my ssh private key into WSL so ansible could use it, but i ran into the issue of "no such file or directory" so i needed to create the directory for it in the WSL home folder, set the permissions for the `ssh` directory so only i could RW and enter it.

Side not: `.ssh` refuses to work if the folder has loose permissions.

Then i needed to copy my private ssh key from windows into the wsl home directory and then set permissions to RW for the same reason as before: If anyone else can read my private key then SSH refuses to use it by default, its a security req not just preference.

After all that i tested the connection with `ansible webservers -i inventory.ini -m ping`

Ran into error "Host key verification failed", the error popped up because i hadnt sshd into the vm from WSL before therefore the host was untrustworthy, fixed it by doing it manually and then ran ping again which then worked and i could move on to writing the playbook.




## Commands used

## Sources