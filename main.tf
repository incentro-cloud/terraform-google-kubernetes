# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# KUBERNETES
# Module for creating a cluster and the node pools.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "cluster" {
  source = "./modules/cluster"

  project_id               = var.project_id
  name                     = var.name
  description              = var.description
  location                 = var.location
  node_locations           = var.node_locations
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count
  network                  = var.network
  subnetwork               = var.subnetwork
  service_account_roles    = var.service_account_roles
  private_cluster_config   = var.private_cluster_config
  networking_mode          = var.networking_mode
  ip_allocation_policy     = var.ip_allocation_policy
}

# ---------------------------------------------------------------------------------------------------------------------
# NODE POOLS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  node_pools = [
    for node_pool in var.node_pools : {
      name               = node_pool.name
      location           = lookup(node_pool, "location", module.cluster.cluster.location)
      cluster            = lookup(node_pool, "cluster", module.cluster.cluster.name)
      service_account    = lookup(node_pool, "service_account", module.cluster.service_account_email)
      initial_node_count = lookup(node_pool, "initial_node_count", null)
      autoscaling        = lookup(node_pool, "autoscaling", null)
      node_count         = lookup(node_pool, "node_count", null)
      node_config        = lookup(node_pool, "node_config", null)
      node_locations     = lookup(node_pool, "node_locations", module.cluster.cluster.node_locations)
    }
  ]
}

module "node_pools" {
  source = "./modules/node_pools"

  project_id = var.project_id
  node_pools = local.node_pools
}
