# Real-time model deployment with R using Azure Container Registry and Azure Kubernetes Service

This repository hosts sample deployment artifacts for the reference architecture "Real-time model deployment with R". You can use these artifacts to deploy a simple containerised predictive service in Azure.

## Prerequisites

To use this repository, you should have the following:

- A recent version of R. It's recommended to use [Microsoft R Open](https://mran.microsoft.com/open), although the standard R distribution from CRAN will work perfectly well.

- The following packages from the [CloudyR Project](http://cloudyr.github.io/) for working with Azure. You can install these packages with `devtools::install_github("cloudyr/AzureRMR")` and `devtools::install_github("cloudyr/AzureContainers")`.
  * [AzureRMR](https://github.com/cloudyr/AzureRMR), a package that implements an interface to Azure Resource Manager
  * [AzureContainers](https://github.com/cloudyr/AzureContainers), an interface to Azure Container Registry (ACR) and Azure Kubernetes Service (AKS)

- [Docker](https://www.docker.com/get-started), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [helm](https://www.helm.sh/) installed on your machine.

- An Azure subscription.

Once you have installed AzureRMR, follow the instructions in the ["Registering a client app"](https://github.com/cloudyr/AzureRMR/blob/master/static/aad_register.md) vignette to create a service principal and register it with Azure Active Directory. You will use this service principal to communicate with Resource Manager and create the resources for this deployment.


## Setting up your deployment

First, you must set your credentials so that R can talk to Azure. Edit the file [`creds.json`](creds.json) so that it contains the following information:

- Your Azure tenant ID
- Your service principal client/app ID
- Your service principal authentication secret.

Next, edit the file [`resource_specs.R`](resource_specs.R) to contain the following:

- Your subscription ID
- The name of the resource group that will hold the resources created
- The location of the resource group
- The names for the ACR and AKS resources to be created
- The number of nodes for the AKS cluster.

## Running the scripts

Note that in general, you should _not_ run these scripts in an automated fashion, eg via `source()` or by pressing <kbd>Ctrl-Shift-Enter</kbd> in RStudio. This is because the process of creating and deploying resources in the cloud involves significant latencies; it's sometimes necessary to wait until a given step has finished before starting on the next step. Because of this, you should step through the scripts line by line, checking at each step that everything works.

### Building the model image

The script [`00_build_image.R`](00_build_image.R) trains a simple model (a random forest for house prices, using the Boston dataset). It then builds a Docker image containing:

- Microsoft Machine Learning Server (only the R components)
- The Azure CLI (necessary to use Model Operationalization)
- the model object plus any packages necessary to use it (randomForest in this case)
- a script that is run on container startup

This image is about 2GB in size.

### Creating the Azure resources

The script [`01_create_resources.R`](01_create_resources.R) creates the resource group and the ACR and AKS resources. Note that creating an AKS resource can take several minutes.

### Installing an ingress controller

The script [`02_install_ingress.R`](02_install_ingress.R) installs nginx on the Kubernetes cluster, and downloads a TLS certificate from Let's Encrypt.

### Deploying the service

The script [`03_deploy_service.R`](03_deploy_service.R) deploys the actual predictive service. First, it pushes the image built previously to the container registry, and then creates a deployment and service on the Kubernetes cluster using that image. This step involves uploading the image to Azure, so may take some time depending on the speed of your Internet connection. At the end, it brings up the Kubernetes dashboard so you can verify that the deployment has succeeded.

### Testing the service

The script [`04_test_service.R`](04_test_service.R) tests that the service works properly (which is not the same as testing that the deployment succeeded). It uses the httr package to send requests to the API endpoint; you can check that the responses are as expected.



