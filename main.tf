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
  service_account          = var.service_account
  preemptible              = var.preemptible
  network                  = var.network
  subnetwork               = var.subnetwork
}

# ---------------------------------------------------------------------------------------------------------------------
# NODE POOLS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  pools = [
    for pool in var.pools : {
      name           = pool.name
      location       = lookup(pool, "location", module.cluster.cluster.location)
      cluster        = lookup(pool, "cluster", module.cluster.cluster.name)
      node_count     = lookup(pool, "node_count", null)
      node_config    = lookup(pool, "node_config", null)
      node_locations = lookup(pool, "cluster", module.cluster.cluster.node_locations)
    }
  ]
}

module "pools" {
  source = "./modules/pools"

  project_id = var.project_id
  pools      = local.pools
}
