environment        = "prod"
location           = "westus2"
vnet_address_space = ["10.30.0.0/16"]
aks_subnet_prefix  = "10.30.1.0/24"

node_vm_size       = "Standard_D4s_v5"
node_min_count     = 2
node_max_count     = 5
acr_sku            = "Premium"
log_retention_days = 90
