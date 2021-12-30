# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORK, SERVICE ACCOUNT, CLUSTER, AND NODE POOLS
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source  = "incentro-cloud/network/google"
  version = "~> 0.3"

  project_id = var.project_id
  name       = "vpc-network"

  subnets = [
    {
      name                     = "default"
      ip_cidr_range            = "10.0.1.0/24"
      region                   = "europe-west1"
      private_ip_google_access = true

      log_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling        = "0.5"
        metadata             = "INCLUDE_ALL_METADATA"
      }
    }
  ]

  rules = [
    {
      name        = "allow-iap-ingress"
      direction   = "INGRESS"
      ranges      = ["35.235.240.0/20"]
      target_tags = ["iap"]

      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "3389"]
        }
      ]
    },
    {
      name        = "allow-internal-ingress"
      direction   = "INGRESS"
      priority    = 65534
      ranges      = ["10.0.1.0/24"]
      source_tags = ["vpc-connector"]

      allow = [
        {
          protocol = "icmp"
        },
        {
          protocol = "tcp"
        },
        {
          protocol = "udp"
        }
      ]
    }
  ]
}

module "kubernetes" {
  source = "../../"

  project_id     = var.project_id
  name           = "cluster-01"
  location       = "europe-west1"
  node_locations = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
  network        = module.network.vpc_id
  subnetwork     = "default"

  private_cluster_config = {}

  node_pools = [
    {
      name       = "node-pool-01"
      node_count = 3

      autoscaling = {
        min_node_count = 3
        max_node_count = 9
      }

      node_config = {
        preemptible  = true
        machine_type = "e2-medium"
      }
    }
  ]

  depends_on = [module.network]
}
