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

# number of nodes for cluster agent pool
# AKS currently only supports one agent pool per cluster
num_nodes <- 3

# VM size for agent pool
node_size <- "Standard_DS2_v3"

# email contact address for Let's Encrypt
email <- "your.email@tenant.com"

# service username
username <- "ml-model-user"

# service password
password <- stop("Must specify a password!")

