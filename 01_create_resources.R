library(AzureRMR)
library(AzureContainers)

# create resource group and resources ---

source("resource_specs.R")

# create ARM login
az <- try(get_azure_login(tenant), silent=TRUE)
if(inherits(az, "try-error"))
    az <- create_azure_login(tenant, auth_type="device_code")

sub <- az$get_subscription(sub_id)

deployresgrp <- (if(sub$resource_group_exists(rg_name))
    sub$get_resource_group(rg_name)
else sub$create_resource_group(rg_name, location=rg_loc))

# create a container registry
deployresgrp$create_acr(acr_name)

# create a Kubernetes cluster -- this will take a few minutes
deployclus_svc <- deployresgrp$create_aks(aks_name,
    enable_rbac=TRUE,
    agent_pools=agent_pool("agentpool", num_nodes, node_size))


# give the cluster access to the registry
deployreg_svc <- deployresgrp$get_acr(acr_name)
deployreg_svc$add_role_assignment(
    principal=deployclus_svc,
    role="Acrpull"
)


