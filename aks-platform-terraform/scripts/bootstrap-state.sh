#!/usr/bin/env bash
# One-time bootstrap: creates the Azure Storage account that holds Terraform
# remote state. Run once per subscription, after `az login`.
#
# Usage: ./scripts/bootstrap-state.sh [location]
set -euo pipefail

LOCATION="${1:-westus2}"
RG="rg-tfstate"
CONTAINER="tfstate"
# Storage account names are global and 3-24 lowercase alphanumerics.
SA="sttfstate$(az account show --query id -o tsv | tr -d '-' | cut -c1-10)"

echo "Subscription : $(az account show --query name -o tsv)"
echo "Resource grp : $RG"
echo "Storage acct : $SA"
echo "Container    : $CONTAINER"

az group create --name "$RG" --location "$LOCATION" --output none

az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

# Protect state from accidental deletion/overwrite.
az storage account blob-service-properties update \
  --account-name "$SA" \
  --resource-group "$RG" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 14 \
  --output none

az storage container create \
  --name "$CONTAINER" \
  --account-name "$SA" \
  --auth-mode login \
  --output none

cat <<EOF

Done. Set these pipeline variables in Azure DevOps:
  tfstateResourceGroup  = $RG
  tfstateStorageAccount = $SA
  tfstateContainer      = $CONTAINER

Grant the pipeline's service principal the
"Storage Blob Data Contributor" role on $SA.
EOF
