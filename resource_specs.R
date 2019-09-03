# change these for your deployment ---

# tenant
tenant <- "your AAD tenant here"

# subscription ID
sub_id <- "your subscription here"

# name of resource group for deployments
rg_name <- "resource group name"

# location for resource group
rg_loc <- "resource group location"

# name of container registry
acr_name <- "container registry name"

# name of Kubernetes cluster
aks_name <- "cluster name"

# name of Key Vault for storing admin password
kv_name <- "key vault name"

# number of nodes for cluster agent pool
# AKS currently only supports one agent pool per cluster
num_nodes <- 5
