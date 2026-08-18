#!/usr/bin/env bash 

# Removes all possible standard locks on RG and ST account and stops AZ backup protection on file share before running tf destroy

RESOURCE_GROUP="Log-OU-rg"
VAULT_NAME="AZfiles-backup"
STORAGE_ACCOUNT=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv)
CONTAINER_NAME="StorageContainer;storage;${RESOURCE_GROUP};${STORAGE_ACCOUNT}"
ITEM_NAME=$(az backup item list --resource-group "$RESOURCE_GROUP" --vault-name "$VAULT_NAME" --backup-management-type AzureStorage --query "[0].name" -o tsv)
STORAGE_SHARE_NAME=$(az storage share-rm list --resource-group "$RESOURCE_GROUP" --storage-account "$STORAGE_ACCOUNT" --query "[0].name" -o tsv)

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container: $CONTAINER_NAME"
echo "Item: $ITEM_NAME"

read -p "About to disable backup protection and delete backup data. Are you sure about this? (y/n) " CONFIRM 
if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 1
fi 

echo "Checking for standard resource locks on the RG..."
RG_LOCK_ID=$(az lock list --resource-group "$RESOURCE_GROUP" --query "[0].id" -o tsv)

if [ -n "$RG_LOCK_ID" ]; then
    echo "Found a lock on the resource group, removing it..."
    MSYS_NO_PATHCONV=1 az lock delete --ids "$RG_LOCK_ID"
else
    echo "No lock found on the resource group"
fi

echo "Checking for standard resource locks on ST account..."
SA_LOCK_ID=$(az lock list --resource-group "$RESOURCE_GROUP" --resource-name "$STORAGE_ACCOUNT" --resource-type Microsoft.Storage/storageAccounts --query "[0].id" -o tsv)

if [ -n "$SA_LOCK_ID" ]; then
    echo "Found a lock on ST account, removing it..."
    MSYS_NO_PATHCONV=1 az lock delete --ids "$SA_LOCK_ID"
else
    echo "No lock found on the ST account"
fi

az backup protection disable \
--resource-group "$RESOURCE_GROUP" \
--vault-name "$VAULT_NAME" \
--container-name "$CONTAINER_NAME" \
--item-name "$ITEM_NAME" \
--backup-management-type AzureStorage \
--workload-type AzureFileShare \
--delete-backup-data true \
--yes 

MAX_ATTEMPTS=6
WAIT_SECONDS=30
ATTEMPT=1
SUCCESS=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    echo "Attempt $ATTEMPT of $MAX_ATTEMPTS: removing share and leased snapshots..."

    if az storage share-rm delete \
    --resource-group "$RESOURCE_GROUP" \
    --storage-account "$STORAGE_ACCOUNT" \
    --name "$STORAGE_SHARE_NAME" \
    --include leased-snapshots \
    --yes; then
    SUCCESS=true
    break
    fi

    echo "Still locked, waiting ${WAIT_SECONDS}s then retrying..."
    sleep $WAIT_SECONDS
    ATTEMPT=$((ATTEMPT + 1))
done

if [ "$SUCCESS" != "true" ]; then
    echo "ERROR: Share unfortunately still locked after $MAX_ATTEMPTS attempts. Manual intervention needed."
    exit 1
fi
    
echo "Protection disabled, share removed with leases go for TF destroy"
