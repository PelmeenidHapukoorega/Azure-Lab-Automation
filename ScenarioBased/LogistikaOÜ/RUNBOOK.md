# Operational Runbook

For architecture reasoning and design decisions behind this setup, see the [main README](./README.md).

>Note: The project folder name includes a non-ASCII character (`Ü`). If you hit odd path-related errors with Git bash or similar tools on Windows, this is a known source of friction: See the CI/CD section of the build log for a related example (`MSYS_NO_PATHCONV`). Lesson i came to learn the hardway.

Instructions for standing up, running, and maintaining the LogistikaOÜ infrastructure. Written for whoever inherits this environment after handoff.

## 1. terraform.tfvars

Create `terraform.tfvars` in the `terraform/` folder (this file is gitignored, never commit it). Fill in the following:

```hcl
subscription_id = "your-azure-subscription-id"

mysql_admin_username = "your-chosen-admin-username"
mysql_admin_password = "your-chosen-strong-password"

deployer_ip = ["your.public.ip/32"]

it_admin_object_id = "the-new-operators-entra-id-object-id"
```

Notes on each value:

* `subscription_id`: your Azure subscription ID. Find it with `az account show --query id -o tsv`.
* `mysql_admin_username` / `mysql_admin_password`: Credentials for the MySQL flexible server admin account. Password must contain at least 3 of: uppercase, lowercase, numbers, special characters.
* `deployer_ip`: your current public IP, needed to allowlist your machine against Key vaults firewall so Terraform can write secrets. This is a list: If you connect from multiple networks, add each one, 1 entry per IP and each ending in `/32`. 

>Note: This is an ongoing maintenance item, not a 1 time setup step: Expect to update it every time your network changes.

* **This changes whenever your IP changes** (router restart, network switch, etc). If you get a 403 from Key vault during `plan`/`apply`, update this value and reapply.
* `it_admin_object_id`: only needed once you have actually created an Entra ID user for whoever operates this environment day to day. Leave as a placeholder until that user exists (see Section 6).

## 2. First deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Review the plan before confirming: Cretes roughly 60+ resources on a fresh deployment.

## 3. Set up CI/CD

The pipeline authenticates to Azure through OIDC (no stored secrets) however it needs the current identitys client ID, which changes every time the identity is recreated.

```bash
az identity show --resource-group Log-OU-rg --name github-actions_cicd --query clientId -o tsv
```

Copy the output. In the GitHub repo: **Settings → Secrets and variables → Actions** set/update these secrets:

* `AZURE_CLIENT_ID`: the value from the command above
* `AZURE_TENANT_ID`: get with `az account show --query tenantId -o tsv`
* `AZURE_SUBSCRIPTION_ID`: same as `subscription_id` above

Trigger the first pipeline run: push a commit touching anything under `ScenarioBased/LogistikaOÜ/testapp/...` or go to the repos **Actions** tab and re-run the last workflow.

## 4. Verify

```bash
terraform output app_service_default_hostname
```

Visit the URL. If you see a placeholder "waiting for content" page or a 503, the App service hasnst picked up the freshly-pushed image yet, restart it:

```bash
az webapp restart --resource-group Log-OU-rg --name logistikaou-fleettracker
```

Wait 1-2 minutes, check again.

## 5. Redeploying / destroying

Before running `terraform destroy`, always run the pre-flight script first: Azure backup places locks and leased snapshots on the storage account that block deletion otherwise:

```bash
./stopbackprotect.sh
```

Confirm when prompted, then:

```bash
terraform destroy
```

On the next deployment, repeat steps 1-4 in full: client ID, pipeline trigger and restart are all required again since the identity and ACR both get new random suffixes on every fresh deploy.

## 6. Enabling the resource group lock

The `CanNotDelete` lock on the resource group (`azurerm_management_lock.rg-level` in `main.tf`) is commented out by default. It cant be applied in the same pass as the rest of the infrastructure: MySQLs VNet integration fails outright (`VirtualNetworkLocked`) if any lock exists on the VNet during creation. This is a known and unresolved limitation of the Terraform provider itself and not something specific to this project (see `REFERENCES.md`).

To enable it:

1. Confirm everything else is deployed and working (steps 1-4 complete)
2. Uncomment `azurerm_management_lock.rg-level` in `main.tf`
3. Run `terraform apply` a second time

## 7. Granting the operator Contributor access

1. Create the operators actual Entra ID user (outside Terraform, deliberately: This project doesnt manage human identities as code since a `destroy` would delete the real account)
2. Get their object ID: `az ad user show --id their@email.com --query id -o tsv`
3. Add that value to `it_admin_object_id` in `terraform.tfvars`
4. Uncomment `azurerm_role_assignment.Contributor` in `main.tf`
5. `terraform plan` and then `terraform apply`

This grants Contributor (not Owner): Operator can manage all resources but cannot grant access to others. Access-management capability stays with whoever holds Owner, deliberately kept separate from day to day operations to avoid single point of failure if the operator is unavailable or leaves.

## 8. Rotating the MySQL password

1. Update `mysql_admin_password` in `terraform.tfvars`
2. `terraform apply`: This updates both the MySQL servers actual password and the Key vault secret in the same pass
3. Restart App Service so it picks up the new secret value:
```bash
az webapp restart --resource-group Log-OU-rg --name logistikaou-fleettracker
```

## 9. Known issues

* **Key Vault 403 during apply/destroy**: Your IP changed. Update `deployer_ip`, reapply. If you are locked out of both `apply` and `destroy` because the read itself is blocked, run `terraform apply -target=azurerm_key_vault.kv` first to update just the firewall rule then retry the full command.
* **App Service still shows old content after a pipeline push**: restart App Service (Section 4). It doesnt reliably detect that `:latest` points to new content on its own.
* **`terraform destroy` fails with `ScopeLocked` or a backup-related error**: Run `./stopbackprotect.sh` first: Azure backups protection lock and leased snapshots arent visible through the standard portal Locks blade and will block deletion silently otherwise.