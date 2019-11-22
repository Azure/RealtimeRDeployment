library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)
deployclus_svc <- deployresgrp$get_aks(aks_name)

deployclus <- deployclus_svc$get_cluster()


# install nginx
deployclus$apply("https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml")
deployclus$apply("https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml")


# get the IP address of the ingress controller
for(i in 1:100)
{
    Sys.sleep(5)
    cluster_resources <- deployclus_svc$list_cluster_resources()
    res_names <- names(cluster_resources)
    ip <- grep("Microsoft.Network/publicIPAddresses", res_names)
    if(!is_empty(ip))
    {
        ip_res <- cluster_resources[[ip]]
        if(ip_res$sync_fields() == "Succeeded")
            break
    }
}

ip_res$sync_fields()

# assign domain name to IP address
ip_res$do_operation(
    body=list(
        location=ip_res$location,
        properties=list(
            dnsSettings=list(domainNameLabel="ml-model"),
            publicIPAllocationMethod=ip_res$properties$publicIPAllocationMethod)),
    encode="json",
    http_verb="PUT")

deployclus$get("service", "--all-namespaces")

deployclus$apply(gsub("resgrouplocation", rg_loc, readLines("yaml/ingress.yaml")))
