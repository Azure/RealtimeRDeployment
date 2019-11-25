library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)

deployclus <- deployresgrp$get_aks(aks_name)$get_cluster()


### install cert-manager

deployclus$apply("https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml",
                 "--validate=false")

# define cluster issuer (can take a few minutes)
for(i in 1:20)
{
    Sys.sleep(30)
    res <- try(deployclus$apply(gsub("@email@", email, readLines("yaml/cluster-issuer.yaml"))))
    if(!inherits(res, "try-error"))
        break
}

if(inherits(res, "try-error"))
    stop("Unable to create cluster issuer")


