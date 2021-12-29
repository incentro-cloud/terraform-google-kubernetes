variable "project_id" {
  type        = string
  description = "The project identifier."
}

variable "name" {
  type = string
}

variable "location" {
  type    = string
  default = ""
}

variable "node_locations" {
  type    = list(string)
}

variable "description" {
  type    = string
  default = ""
}

variable "remove_default_node_pool" {
  type    = bool
  default = true
}

variable "initial_node_count" {
  type    = number
  default = 1
}

variable "network" {
  type    = string
  default = "default"
}

variable "subnetwork" {
  type    = string
  default = ""
}

variable "pools" {
  type        = any
  description = "The node pools."
}
