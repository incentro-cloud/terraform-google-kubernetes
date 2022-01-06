# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CLUSTER
# Submodule for creating a cluster including a service account and the roles.
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
# SERVICE ACCOUNT AND ROLES (IAM MEMBERS, NON-AUTHORITATIVE)
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "account" {
  account_id   = var.name
  display_name = "Service account for ${var.name}"
  project      = var.project_id
}

locals {
  service_account_roles = concat(var.service_account_roles, [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(local.service_account_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.account.email}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_cluster" "cluster" {
  provider = google-beta

  name                        = var.name
  description                 = var.description
  project                     = var.project_id
  location                    = var.location
  node_locations              = var.node_locations
  remove_default_node_pool    = var.remove_default_node_pool
  initial_node_count          = var.initial_node_count
  network                     = var.network
  subnetwork                  = var.subnetwork
  networking_mode             = var.networking_mode
  enable_intranode_visibility = var.enable_intranode_visibility

  dynamic "monitoring_config" {
    for_each = var.monitoring_config == {} ? [] : [var.monitoring_config]
    content {
      enable_components = lookup(monitoring_config.value, "enable_components", "WORKLOADS")
    }
  }

  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config == {} ? [] : [var.private_cluster_config]
    content {
      enable_private_nodes    = lookup(private_cluster_config.value, "enable_private_nodes", true)
      enable_private_endpoint = lookup(private_cluster_config.value, "enable_private_endpoint", false)
      master_ipv4_cidr_block  = lookup(private_cluster_config.value, "master_ipv4_cidr_block", null)
    }
  }

  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy == {} ? [] : [var.ip_allocation_policy]
    content {
      cluster_secondary_range_name  = lookup(ip_allocation_policy.value, "cluster_secondary_range_name", null)
      services_secondary_range_name = lookup(ip_allocation_policy.value, "services_secondary_range_name", null)
      cluster_ipv4_cidr_block       = lookup(ip_allocation_policy.value, "cluster_ipv4_cidr_block", null)
      services_ipv4_cidr_block      = lookup(ip_allocation_policy.value, "services_ipv4_cidr_block ", null)
    }
  }
}
