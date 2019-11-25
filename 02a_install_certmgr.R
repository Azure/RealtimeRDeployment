library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)

deployclus <- deployresgrp$get_aks(aks_name)$get_cluster()


### install cert-manager and get a cert from LetsEncrypt

# Install the CustomResourceDefinition resources separately
deployclus$apply("https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml
", "--validate=false")

# Create the namespace for cert-manager
deployclus$kubectl("create namespace cert-manager")

# Label the cert-manager namespace to disable resource validation
deployclus$kubectl("label namespace cert-manager cert-manager.io/disable-validation=true")

# Add the Jetstack Helm repository
deployclus$helm("repo add jetstack https://charts.jetstack.io")
deployclus$helm("repo update")


# helm command for v3.0
deployclus$helm("install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.11.0")

# helm command for v2.x
# deployclus$helm("install jetstack/cert-manager --name cert-manager --namespace cert-manager --version v0.11.0")

# define cluster issuer and get certificate
for(i in 1:100)
{
    Sys.sleep(5)
    res <- try(deployclus$apply(gsub("@email@", email, readLines("yaml/cluster-issuer.yaml"))))
    if(!inherits(res, "try-error"))
        break
}

if(inherits(res, "try-error"))
    stop("Unable to create cluster issuer")


deployclus$kubectl("describe clusterIssuer letsencrypt-staging")
