### Author: Hong Ooi

# Real-time model deployment with R using Azure Container Registry and Azure Kubernetes Service

## Overview

This repository hosts deployment artifacts for the reference architecture "Real-time model deployment with R". You can use these artifacts to deploy a containerised predictive service in Azure.

## Design

![](https://github.com/mspnp/architecture-center/blob/master/docs/reference-architectures/ai/_images/realtime-scoring-r.png)

The workflow in this repository builds a sample machine learning model: a random forest for housing prices, using the Boston housing dataset that ships with R. It then builds a Docker image with the components to host a predictive service:
- The base R runtime
- the model object plus any packages necessary to use it (randomForest in this case).
- the [Plumber](https://www.rplumber.io/) package for exposing R code as an API.
- a script that is run on container startup to create the API.

This image is pushed to a Docker registry hosted in Azure, and then deployed to a Kubernetes cluster, also in Azure.

## Prerequisites

To use this repository, you will need the following:

- A recent version of R. It's recommended to use [Microsoft R Open](https://mran.microsoft.com/open), although the standard R distribution from CRAN will work perfectly well.
- The [AzureContainers](https://cran.r-project.org/package=AzureContainers) package, version 1.2.0 or later, for working with containers in Azure.
- [Docker](https://www.docker.com/get-started), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [helm 3](https://www.helm.sh/) installed on your machine.

- An Azure subscription.

To generate the service authentication password, you should also have the `htpasswd` utility installed. On Debian, Ubuntu and SUSE, this is part of the `apache2-utils` distribution; on Red Hat and CentOS, it is part of `httpd-tools`. See below for alternatives if this is not installed or unavailable for your OS.

## Setup

Edit the file [`resource_specs.R`](resource_specs.R) to contain the following:

- Your Azure Active Directory tenant. This can be either your directory name or a GUID.
- Your subscription ID.
- The name of the resource group that will hold the resources created. The resource group will be created if it does not already exist.
- The location of the resource group. For a list of regions where AKS is available, see [this page](https://azure.microsoft.com/global-infrastructure/services/?products=kubernetes-service).
- The names for the ACR and AKS resources to be created. The name of the AKS resource, along with its location, will also be used for the domain name label of the cluster.
- The number of nodes and node VM size for the AKS cluster.
- Your email address. This is used to obtain a TLS certificate from Let's Encrypt.
- A (generic) username and password for the predictive service.

## Deployment steps

### Generate the service password

You'll need to generate a password to secure the service against unauthorized access. If you are on Linux and have `htpasswd` installed, run this from the commandline, substituting the `password` and `username` from your `resource_specs.R` configuration file:

```
echo <password> | htpasswd -c -i auth <username>
```

This will create a file `auth` in the current directory that contains the encrypted password. If you don't have `htpasswd`, you can create the file using the htpasswd generator site:

- Browse to https://www.htaccesstools.com/htpasswd-generator/
- Enter the username and password from your `resource_specs.R` file
- Click on "Create .htpasswd file"
- Select the generated text, and save it into a file named `auth`.

Next, run the following scripts in order.

### Building the model image

The script [`00_train_model.R`](00_train_model.R) trains a simple model (a random forest for house prices, using the Boston dataset), and saves the model object to a .RDS file. This step is optional, as the repository already contains a suitable model object.

### Creating the Azure resources

The script [`01_create_resources.R`](01_create_resources.R) creates the necessary Azure resources for the deployment. Note that creating an AKS cluster can take several minutes.

### Installing an ingress controller

The script [`02_install_ingress.R`](02_install_ingress.R) installs the Traefik reverse proxy on the Kubernetes cluster and sets the cluster's domain name.

### Deploying the service

The script [`03_deploy_service.R`](03_deploy_service.R) pushes the model image to Azure, and deploys the predictive service.

## Testing the service

The script [`04_test_service.R`](04_test_service.R) tests that the service works properly, by sending a request to the API endpoint; you can check that the responses are as expected.



