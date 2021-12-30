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
  name                     = var.name
  description              = var.description
  project                  = var.project_id
  location                 = var.location
  node_locations           = var.node_locations
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count
  network                  = var.network
  subnetwork               = var.subnetwork

  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config == {} ? [] : [var.private_cluster_config]
    content {
      enable_private_endpoint = lookup(node_config.value, "enable_private_endpoint", true)
    }
  }
}
