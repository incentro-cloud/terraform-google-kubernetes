variable "project_id" {
  type        = string
  description = "The project identifier."
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "node_locations" {
  type = list(string)
}

variable "description" {
  type = string
}

variable "remove_default_node_pool" {
  type = bool
}

variable "initial_node_count" {
  type = number
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "networking_mode" {
  type = string
}

variable "enable_intranode_visibility" {
  type = bool
}

variable "ip_allocation_policy" {
  type = any
}

variable "service_account_roles" {
  type = list(string)
}

variable "private_cluster_config" {
  type = any
}

variable "monitoring_config" {
  type    = any
  default = {}
}
