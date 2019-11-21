library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)

deployclus <- deployresgrp$get_aks(aks_name)$get_cluster()


deployclus$helm("repo add jetstack https://charts.jetstack.io")
deployclus$helm("repo update")

inst_certmgr <- gsub("\n", " ", "install jetstack/cert-manager
--namespace ingress-nginx
--set rbac.create=false
--set serviceAccount.create=false
--generate-name")

deployclus$helm(inst_certmgr)

# deploy certificate and ingress controller
deployclus$apply(gsub("resgrouplocation", rg_loc, readLines("yaml/cluster-issuer.yaml")))
deployclus$apply(gsub("resgrouplocation", rg_loc, readLines("yaml/certificates.yaml")))
