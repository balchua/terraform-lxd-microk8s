variable "cluster_token" {
  type        = string
  default     = "PoiuyTrewQasdfghjklMnbvcxz123409"
  description = "The cluster token to use to join a node.  Must be 32 alphanumeric long." 
}

variable "cluster_token_ttl_seconds" {
  type        = number
  default     = 3600
  description = "The cluster token ttl to use when joining a node, default 3600 seconds."
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Number of nodes"
}


variable "cluster_name" {
  type    = string
  default = "nautilus"
}

variable "microk8s_channel" {
  type        = string
  default     = "1.20/stable"
  description = "The MicroK8s channel to use"
}

