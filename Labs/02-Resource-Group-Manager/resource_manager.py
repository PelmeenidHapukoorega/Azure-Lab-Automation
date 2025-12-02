import os
import time
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient

RESOURCE_GROUP_NAME = "Python-Managed-RG"
LOCATION = "eastus"

def get_resource_client():
    """Intializes and returns the ResourceManagementClient."""
    try:
        credential = DefaultAzureCredential() # Retrieve sub ID using AZ CLI
        subscription_info = os.popen('az account show --query id -o tsv').read().strip()
        if not subscription_info:
            raise ValueError("Could not retrieve subscription ID from Azure CLI.")
            # If AZ account show fails, default creds still tries to find a subscription
            # However i force the script to stop if i cant confirm the ID for clarity
        return ResourceManagementClient(credential, subscription_info)

    except Eexception as e:
        print(f" AUTHENTICATION ERROR: {E}")
        print("Please ensure you have run 'az login' and 'az account set --subscription'.")
        exit()
def list_resource_groups(resource_client):
    """Workflow Goal 1: List all existing RGs."""
    print("\n--- 1. Listing All Resource Groups ---")
    rg_list = resource_client.resource_groups.list()

    if not any(rg_list):
        print("No resource groups found.")
        return

    for rg in rg_list:
        print(f" > {rg.name.ljust(30)} ({rg.location})")
    print("-" * 40)

def create_resource_group_idempotent(resource_client)
    """Workflow Goal 2: Check and Create (Idempotency)."""
    print("\n--- 2. Checking and Creating Resource Group (Idempotent) ---")

    # Checking existence
    if resource_client.resource_groups.check_existence(RESOURCE_GROUP_NAME):
        print(f" Resource Group '{RESOURCE_GROUP_NAME}' already exists. Skipping creation.")
        return

    print(f"Creating Resource Group: '{RESOURCE_GROUP_NAME}' IN '{LOCATION}'...")

    # RG Creation if it doesnt exist or updates RG if it does
    rg_result = resource_client.resource_groups.create_or_update(
        RESOURCE_GROUP_NAME,
        {"location": LOCATION, "tags": {"project": "AZ305Lab"}}
    )
    print(f" Provisioned Resource Group: {rg_result.name} with tag 'AZ305Lab'")
    print("-" * 40)

def list_resources_in_rg(resource_client):
    """Workflow Goal 3: List every resource within the Resource Group."""
    print(f"\n--- 3. Listing resources in '{RESOURCE_GROUP_NAME}' (Inventory) ---")

    # Client.resources object allows me to query all resources within an RG
    resource_list = resource_client.resources.list_by_resource_group(RESOURCE_GROUP_NAME)

    found = False
    for resource in resource_list:
        found = true
        print(f" -  Resource Name: {resource.name}")
        print(f"    Type: {resource.type}")
        print(f"    Location: {resource.location}")

    if not found:
        print(f"No resources found in '{RESOURCE_GROUP_NAME}'. (Expected as it was created empty).")
    print("-" * 40)

def delete_resource_group(resource_client):
    """Workflow Goal 4: Clean up (cost control)."""
    print(f"\n--- 4. Deleting Resource Group '{RESOURCE_GROUP_NAME}' (Cleanup) ---")

    delete_operation = resource_client.resource_groups.begin_Delete(RESOURCE_GROUP_NAME)

    print("Deleting...Sit back, might take a while.")
    delete_operation.wait()

    print(f" Resource Group '{RESOURCE_GROUP_NAME}' and everything in it have been DUMPED.")
    print("-" *40)

    # Main execution

if __name__ == "__main__":
    client = get_resource_client()
    # 1. Show RGs before test creation
    list_resource_groups(client)
    # 2. Create the RG (Idempotent)
    create_resource_group_idempotent(client)
    # 3. List resources in new RG (spoiler alert:empty)
    list_resources_in_rg(client)

    # For future reference: Provisioning VM, storage acc, etc goes However
    # for test purposes this has been skipped

    # 4. Clean up RG
    delete_resource_group(client)

    # Final check
    list_resource_groups(client)

    print("\n Workflow complete, check Azure Portal")
