library(AzureRMR)
library(AzureContainers)

# resource/service objects
source("resource_specs.R")

deployresgrp <- get_azure_login(tenant)$
    get_subscription(sub_id)$
    get_resource_group(rg_name)


### deploy predictive model as a service

# create Docker image containing the model and startup script
call_docker("build -t ml-model .")

# push image to registry
deployreg_svc <- deployresgrp$get_acr(acr_name)
deployreg <- deployreg_svc$get_docker_registry()
deployreg$push("ml-model")


deployclus <- deployresgrp$get_aks(aks_name)$get_cluster()

# namespace for all our objects
deployclus$kubectl("create namespace ml-model")

# basic authentication password
# you must have an 'auth' file generated with htpasswd, or copied from https://www.htaccesstools.com/htpasswd-generator/
deployclus$kubectl("create secret generic ml-model-secret --from-file=auth --namespace ml-model")

### create the deployment, service and ingress route
deployclus$create(gsub("@registryname@", acr_name, readLines("yaml/deployment.yaml")))
deployclus$create("yaml/service.yaml")
deployclus$apply(gsub("@resgrouplocation@", rg_loc, readLines("yaml/ingress.yaml")))


### check on deployment/service status
deployclus$get("deployment", "--namespace ml-model")
deployclus$get("service", "--namespace ml-model")
deployclus$get("pods", "--namespace ml-model")

# human-readable text
deployclus$kubectl("describe deployment --namespace ml-model")
deployclus$kubectl("describe service --namespace ml-model")
deployclus$kubectl("describe pods --namespace ml-model")

