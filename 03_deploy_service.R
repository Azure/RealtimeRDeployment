library(AzureRMR)
library(AzureContainers)

# resource/service objects
source("resource_specs.R")

deployresgrp <- get_azure_login(tenant)$
    get_subscription(sub_id)$
    get_resource_group(rg_name)


### deploy predictive model as a service

# package up the model and container startup script into an image
cmdline <- paste0("build -t ml-model .")
call_docker(cmdline)

# push image to registry
deployreg_svc <- deployresgrp$get_acr(acr_name)
deployreg <- deployreg_svc$get_docker_registry()

deployreg$push("ml-model")


### create the deployment, service and ingress route
deployclus <- deployresgrp$get_aks(aks_name)$get_cluster()

# namespace for all our objects
deployclus$kubectl("create namespace ml-model")

# basic authentication password
# you must have an 'auth' file generated with htpasswd, or from https://www.htaccesstools.com/htpasswd-generator/
deployclus$create("secret", "generic ml-model-secret -f auth --namespace ml-model")

deployclus$create(gsub("@registryname@", acr_name, readLines("yaml/deployment.yaml")))
deployclus$create("yaml/service.yaml")
deployclus$apply(gsub("@resgrouplocation@", rg_loc, readLines("yaml/ingress.yaml")))


### check on deployment/service status

deployclus$get("all --namespace ml-model")
deployclus$get("clusterIssuer", "--all-namespaces")
deployclus$get("certificate", "--namespace ml-model")
deployclus$get("deployment", "--all-namespaces")
deployclus$get("service", "--all-namespaces")
deployclus$get("pods", "--all-namespaces")

# human-readable text
deployclus$kubectl("describe clusterIssuer letsencrypt-staging")
deployclus$kubectl("describe certificate ml-model-secret --namespace ingress-nginx")
deployclus$kubectl("describe certificateRequest ml-model-secret-442839315 --namespace ingress-nginx")
deployclus$kubectl("describe pods --namespace ingress-nginx")

# display the dashboard
deployclus$show_dashboard()
