environment        = "dev"
location           = "westus2"
vnet_address_space = ["10.10.0.0/16"]
aks_subnet_prefix  = "10.10.1.0/24"

node_vm_size   = "Standard_D2s_v5"
node_min_count = 1
node_max_count = 2
acr_sku        = "Basic"
