library(AzureRMR)
library(AzureContainers)

# resource/service objects ---
source("resource_specs.R")

sub <- get_azure_login(tenant)$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)
deployclus_svc <- deployresgrp$get_aks(aks_name)

deployclus <- deployclus_svc$get_cluster()


# install traefik
deployclus$helm("repo add stable https://kubernetes-charts.storage.googleapis.com/")
deployclus$helm("repo update")

traefik_yaml <- tempfile(fileext=".yaml")
writeLines(gsub("@email@", email, readLines("yaml/traefik-values.yaml")), traefik_yaml)

deployclus$helm(paste("install traefik-ingress stable/traefik --namespace kube-system --values", traefik_yaml))


# wait until ingress controller has a public IP address
for(i in 1:100)
{
    res <- read.table(text=deployclus$get("service", "--all-namespaces")$stdout, header=TRUE, stringsAsFactors=FALSE)
    has_ip <- res$EXTERNAL.IP[res$NAME == "traefik"] != "<pending>"
    if(has_ip)
        break
    Sys.sleep(10)
}

if(!has_ip)
    stop("Public IP address not assigned to ingress controller")

# get the public IP resource of the ingress controller
cluster_resources <- deployclus_svc$list_cluster_resources()
ip <- grep("Microsoft.Network/publicIPAddresses", names(cluster_resources))
if(is_empty(ip))
    stop("Ingress public IP resource not found")
ip_res <- cluster_resources[[ip]]
ip_res$sync_fields()

# assign domain name to IP address
ip_res$do_operation(
    body=list(
        location=ip_res$location,
        properties=list(
            dnsSettings=list(domainNameLabel="ml-model"),
            publicIPAllocationMethod=ip_res$properties$publicIPAllocationMethod
        )
    ),
    http_verb="PUT"
)

