module "microk8s" {
  source                     = "../"
  node_count                 = "1"
  microk8s_channel           = "latest/edge"
  cluster_token_ttl_seconds  = 3600
  cluster_name               = "nemo"
}

