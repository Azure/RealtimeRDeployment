library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)

deployclus <- deployresgrp$get_aks(aks_name)$get_cluster()


### install cert-manager and get a cert from LetsEncrypt

deployclus$apply("https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml")

# define cluster issuer certificate and get certificate
deployclus$apply(gsub("resgrouplocation", rg_loc, readLines("yaml/cluster-issuer.yaml")))
deployclus$apply(gsub("resgrouplocation", rg_loc, readLines("yaml/certificates.yaml")))
