library(AzureGraph)
library(AzureRMR)
library(AzureContainers)

# create resource group and resources ---

source("resource_specs.R")

# create ARM and Graph logins
az <- try(get_azure_login(tenant), silent=TRUE)
if(inherits(az, "try-error"))
    az <- create_azure_login(tenant, app=app_id, password=password)

gr <- try(get_graph_login(tenant), silent=TRUE)
if(inherits(gr, "try-error"))
    gr <- create_graph_login(tenant, app=app_id, password=password)

sub <- az$get_subscription(sub_id)

deployresgrp <- (if(sub$resource_group_exists(rg_name))
    sub$get_resource_group(rg_name)
else sub$create_resource_group(rg_name, location=rg_loc))

# create a container registry
deployresgrp$create_acr(acr_name)

# create a Kubernetes cluster
# this will take several minutes (usually 10-20)
deployclus_svc <- deployresgrp$create_aks(aks_name,
    enable_rbac=TRUE,
    agent_pools=aks_pools("agentpool", num_nodes, node_size))


# give the cluster access to the registry
aks_app_id <- deployclus_svc$properties$servicePrincipalProfile$clientId
deployreg_svc <- deployresgrp$get_acr(acr_name)
deployreg_svc$add_role_assignment(
    principal=AzureGraph::get_graph_login(tenant)$get_app(aks_app_id),
    role="Acrpull"
)


