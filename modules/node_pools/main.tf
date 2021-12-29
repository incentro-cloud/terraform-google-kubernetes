# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NODE POOLS
# Submodule for creating the node node_pools.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# NODE POOLS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_node_pool" "node_pools" {
  for_each           = { for node_pool in var.node_pools : lower(node_pool.name) => node_pool }
  name               = each.value.name
  project            = var.project_id
  location           = each.value.location
  cluster            = each.value.cluster
  node_count         = each.value.node_count
  node_locations     = each.value.node_locations
  initial_node_count = each.value.initial_node_count

  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling") == null ? [] : [each.value.autoscaling]
    content {
      min_node_count = autoscaling.value.min_node_count
      max_node_count = autoscaling.value.max_node_count
    }
  }

  dynamic "node_config" {
    for_each = lookup(each.value, "node_config") == null ? [] : [each.value.node_config]
    content {
      preemptible     = lookup(node_config.value, "preemptible", false)
      machine_type    = lookup(node_config.value, "machine_type", "e2-medium")
      service_account = each.value.service_account
      oauth_scopes    = lookup(node_config.value, "oauth_scopes", ["https://www.googleapis.com/auth/cloud-platform"])
    }
  }
}