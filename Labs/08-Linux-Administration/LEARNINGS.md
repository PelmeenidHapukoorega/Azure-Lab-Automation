# Learnings

This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.

## Decisions i made and errors i ran into

The purpose of this lab was to dive more into Linux once more.

I created terraform file to deploy the VM into Azure to later SSH into it and actually do stuff in there, so for ease of use i used resources from Lab 7 and added monitoring agent extension to the VM since Checkov had flagged it for me in the previous project.

Forgot to include `type` in the VM extension resource, without it the agent wont install because it explicitly tells Azure which specific extension do you want to be deployed on the VM

SSHd into VM and went through basic commands to get back the feel of operating Linux like i used to.

Created testuser and appended sudo the users existing group membership using `-aG sudo`. Without append it would remove the user from every other group and only leave it at sudo which would then lock me out of things.

Leading character in permission strings for remembrance:

* `-` for files
* `d` for directory
* `1` for symlink


`#!/bin/bash` tells the OS which interpreter to use to run scripts aka shebang line, without it linux might run it with a differnet shell which then would behave differently.

`>` writes output to file and overwriting everything that was before
`>>` appends output to the file and adding to the end without deleting existing content.
`tee -a` does both at once, prints to the terminal and appends to the file.

Created a cron job and added `2>&1` so that if the script were to throw errors it wouldnt get lost but instead be logged where outputs would be logged in other words i redirected possible error logs > to stdout.

Cron jobs run as the user who created it, if the job tries to write to the directory that use has no write access to, then it fails silently.

Therefore the lesson here is to check permissions on the output path.
Rule:

* `0` stdin (input)
* `1` stdout (output)
* `2` stderr (error output)

Then i tried adding users, switching permissions, how to check hashed passwords.

Tried different `systemctl` commands in order to understand how to check, start, disable, verify and check if services would start at boot. Everything that will i.e everything relevant for an administrator to know what to check and do.

Ive listed below the commands i used for this lab, overall the purpose was to familiarise myself with linux again since the last time i touched it heavily was years ago. 

Ill keep this lab for linux learning specifically and incorporate it with azure too, so whenever i wanna test smt on linux ill use this.

Honestly this was on purpose to be basic, cant really deep dive into linux later on if i havent refreshed the basics first.

## Commands used

* `adduser <username>`: Create a new user
* `usermod -aG <group> <user>`: Add user to a group, -a means append to existing groups, -G specifies the group
* `groups <username>`: Show which groups a user belongs to
* `cat /etc/passwd`: List all users on the system
* `sudo cat /etc/shadow`: Show hashed passwords, root access only

* `ls -la`: List files with full permissions and ownership
* `chmod u+x <file>`: Add execute permission for owner
* `chmod g-w <file>`: Remove write permission from group
* `touch <file>`: Create an empty file

* `systemctl status <service>`: Check if a service is running
* `systemctl start <service>`: Start a service
* `systemctl stop <service>`: Stop a service
* `systemctl enable <service>`: Make service start automatically on boot
* `systemctl is-enabled <service>`: Check if service is set to start on boot

* `journalctl -u <service>`: View logs for a specific service
* `journalctl -u <service> -f`: Follow logs in real time
* `journalctl --since "10 minutes ago"`: View recent system logs

* `#!/bin/bash`: Shebang line, tells the OS which interpreter to use to run the script
* `>`: Redirect output to file, overwrites existing content
* `>>`: Redirect output to file, appends to existing content
* `tee -a <file>`: Print output to terminal and append to file at the same time
* `2>&1`: Redirect stderr to stdout so errors get captured in the same place as normal output

* `crontab -e`: Edit cron jobs for the current user
* `crontab -l`: List current cron jobs
* `*/5 * * * * <command>`: Cron schedule syntax, runs command every 5 minutes

* `top`: Real-time process and resource monitor
* `df -h`: Show disk usage per filesystem in human readable format
* `free -h`: Show memory usage, total, used and available

* `sudo apt update`: Update the package list
* `sudo apt install <pkg> -y`: Install a package without confirmation prompt
* `curl http://localhost`: Test HTTP response from the local web server

## Sources

### User and permission management
- https://linux.die.net/man/1/chmod
- https://linux.die.net/man/8/usermod

### systemd and services
- https://www.freedesktop.org/software/systemd/man/systemctl.html
- https://wiki.archlinux.org/title/systemd

### journalctl
- https://www.freedesktop.org/software/systemd/man/journalctl.html

### Bash scripting
- https://www.gnu.org/software/bash/manual/bash.html
- https://tldp.org/LDP/abs/html/

### Cron
- https://man7.org/linux/man-pages/man5/crontab.5.html
- https://crontab.guru

### nginx
- https://nginx.org/en/docs/
- https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04

### System monitoring
- https://man7.org/linux/man-pages/man1/top.1.html
- https://man7.org/linux/man-pages/man1/free.1.html
- https://man7.org/linux/man-pages/man1/df.1.html