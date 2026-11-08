# AKS Platform with Terraform and Azure DevOps

Production-style Azure Kubernetes Service platform defined entirely as code, deployed through a multi-stage Azure DevOps pipeline with plan review, manual approvals, and security scanning.

## What it builds

Per environment (`dev`, `test`, `prod`):

- Resource group
- Virtual network, AKS subnet, and network security group
- Azure Container Registry (no admin user; AKS pulls via the `AcrPull` role)
- AKS cluster with autoscaling node pool, Azure CNI, network policy, workload identity, and Container Insights
- Log Analytics workspace

Terraform state lives in an Azure Storage account (versioned, Azure AD auth, no access keys).

## Architecture

```
 Developer ──push──> GitHub / Azure Repos
                          │
                          ▼
              ┌─────────────────────────┐
              │  Azure DevOps Pipeline  │
              │  Validate (fmt, validate,│
              │  tflint, Checkov)       │
              └───────────┬─────────────┘
                          ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │   dev    │ → │   test   │ → │   prod   │
   │ plan     │   │ plan     │   │ plan     │
   │ apply    │   │ approve  │   │ approve  │
   │          │   │ apply    │   │ apply    │
   └────┬─────┘   └────┬─────┘   └────┬─────┘
        ▼              ▼              ▼
   VNet + ACR + AKS + Log Analytics (one stack per env)
        │
   Remote state: Azure Storage (tfstate container, one key per env)
```

> Tip: replace this ASCII sketch with a diagram exported from draw.io or Mermaid for your portfolio version.

## Repository layout

```
infra/
  main.tf  variables.tf  outputs.tf  versions.tf
  env/                 dev.tfvars  test.tfvars  prod.tfvars
  modules/
    network/           VNet, subnet, NSG
    acr/               Container registry
    aks/               AKS cluster, Log Analytics, AcrPull role
pipelines/
  azure-pipelines.yml  Validate -> dev -> test -> prod
  templates/terraform-env.yml   Reusable plan + approve + apply stage
scripts/
  bootstrap-state.sh   One-time remote state setup
```

## Prerequisites

- Azure subscription and the Azure CLI (`az login`)
- Terraform >= 1.6
- An Azure DevOps organization and project

## Deploy

### 1. Bootstrap remote state (once)

```bash
./scripts/bootstrap-state.sh westus2
```

Note the three values it prints.

### 2. Configure Azure DevOps

1. **Service connection:** create an Azure Resource Manager connection (workload identity federation recommended) named `sc-azure-aks-platform`. Give its identity `Contributor` and `User Access Administrator` on the subscription (the AcrPull role assignment needs the latter), plus `Storage Blob Data Contributor` on the state storage account.
2. **Environments:** create `aks-dev`, `aks-test`, `aks-prod`. Add an **Approvals** check to `aks-test` and `aks-prod`.
3. **Variables:** add `tfstateResourceGroup`, `tfstateStorageAccount`, `tfstateContainer` (pipeline variables or a variable group).
4. **Pipeline:** create a new pipeline pointing at `pipelines/azure-pipelines.yml`.

### 3. Run

Push to `main`. The pipeline validates, plans and applies `dev`, then waits for approval before `test` and `prod`.

### Run locally (optional)

```bash
cd infra
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_USE_AZUREAD=true

terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=<your-storage-account>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=aks-platform-dev.tfstate"

terraform plan -var-file=env/dev.tfvars
```

Connect to the cluster with the command in the `get_credentials_command` output.

## Design decisions

- **Plan once, apply that plan.** The plan file is published as an artifact and the apply stage applies exactly what was reviewed.
- **No secrets in the repo.** Authentication uses the service connection identity and Azure AD for state access.
- **One module per concern** so network, registry, and cluster can be reused or swapped independently.
- **Per-environment sizing via tfvars**, with separate state files and non-overlapping address spaces.
- **Security scanning in CI.** Checkov runs in soft-fail mode so findings are visible without blocking; tighten it once you triage the results.

## Cost notes

Rough monthly cost for `dev` is a small fraction of `prod`: one or two `Standard_D2s_v5` nodes, a Basic registry, and a small Log Analytics workspace. Prices vary by region, so check the Azure pricing calculator. **Destroy environments you are not using.**

## Destroy

```bash
cd infra
terraform destroy -var-file=env/dev.tfvars
```

Then delete the `rg-tfstate` resource group if you no longer need remote state.

## Possible extensions

- Private AKS cluster with a jump host or private endpoints
- Azure Key Vault with the CSI secrets driver
- Azure Policy assignments and Defender for Containers
- Separate user node pool and spot node pool
- Terraform tests (`terraform test`) and Infracost in the pipeline
