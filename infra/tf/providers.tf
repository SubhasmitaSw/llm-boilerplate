terraform {

  # backend "s3" {
  #   # specify the tfsate file location
  #   region = "lon1"               # Region of the S3 bucket
  #   bucket = "kunal-demo"        # Name of the S3 bucket
  #   key    = "llm-boilerplate-backend.tfstate" # Name of the tfstate file

  #   # skip all the AWS related checks
  #   skip_metadata_api_check     = true
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  #   skip_s3_checksum            = true
  #   skip_requesting_account_id  = true
  #   use_path_style              = true

  # }

  required_providers {
    #  User to provision resources (firewal / cluster) in civo.com
    civo = {
      source  = "civo/civo"
      version = "1.1.2"
    }

    # Used to output the kubeconfig to the local dir for local cluster access
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }

    # Used to provision helm charts into the k8s cluster
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

# Configure the Civo Provider
provider "civo" {
  token  = var.civo_token
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = civo_kubernetes_cluster.cluster.api_endpoint
    client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-certificate-data)
    client_key             = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).clusters[0].cluster.certificate-authority-data)
  }
}

provider "kubernetes" {
  host                   = civo_kubernetes_cluster.cluster.api_endpoint
  client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).clusters[0].cluster.certificate-authority-data)
}