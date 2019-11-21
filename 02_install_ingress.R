library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)
deployclus_svc <- deployresgrp$get_aks(aks_name)

deployclus <- deployclus_svc$get_cluster()


### install ingress controller and enable https

# install nginx ---
deployclus$apply("https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml")
deployclus$apply("https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml")


# check that the ingress controller is up, and an external IP address has been assigned
# this can again take several seconds
deployclus$get("service", "--all-namespaces")

# get the IP address resource
# run this after an external IP has been assigned to the ingress controller
cluster_resources <- sub$
    get_resource_group(deployclus_svc$properties$nodeResourceGroup)$
    list_resources()

ip_res <- cluster_resources[[grep("IPAddresses", names(cluster_resources))]]
ip_res$sync_fields()

# assign domain name to IP address of cluster endpoint
ip_res$do_operation(
    body=list(
        location=ip_res$location,
        properties=list(
            dnsSettings=list(domainNameLabel="ml-model"),
            publicIPAllocationMethod=ip_res$properties$publicIPAllocationMethod)),
    encode="json",
    http_verb="PUT")

deployclus$apply(gsub("resgrouplocation", rg_loc, readLines("yaml/ingress.yaml")))
