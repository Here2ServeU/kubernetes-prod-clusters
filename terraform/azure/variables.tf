variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group" {
  type        = string
  description = "Azure Resource Group name"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in default pool"
  default     = 2
}