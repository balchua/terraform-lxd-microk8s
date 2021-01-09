resource "lxd_container" "microk8s-nodes" {
  name        = "mk8s-node-${var.cluster_name}-${count.index}" 
  count       = var.node_count
  image       = "ubuntu:20.04"
  ephemeral   = false
  profiles    = ["default",lxd_profile.microk8s-profile.name]

  file {
    content = file("${path.module}/templates/rc.local")
    uid = 0
    gid = 0
    mode = "0700"
    target_file = "/etc/rc.local"
  }

  file {
    content = data.template_file.join_token.rendered
    uid = 0
    gid = 0
    mode = "0700"
    target_file = "/usr/local/bin/join.sh"
  }
  
  file {
      content = data.template_file.add_node.rendered
      uid = 0
      gid = 0
      mode = "0700"
      target_file = "/usr/local/bin/add-node.sh"
  }  
}

resource "null_resource" "setup_token" {  
  depends_on = [lxd_container.microk8s-nodes]  
  provisioner "local-exec" {
    command = "lxc exec ${lxd_container.microk8s-nodes[0].name} -- sh -c \"sleep 10; /usr/local/bin/add-node.sh\""
  }
}

resource "null_resource" "get_kubeconfig" {  
  depends_on = [null_resource.setup_token] 
  provisioner "local-exec" {
    command = "lxc file pull ${"mk8s-node-${var.cluster_name}-0"}/client.config /tmp/client.config"
  }
}

data "template_file" "add_node" {
  template = file("${path.module}/templates/add-node.sh")
  vars = {
    cluster_token_ttl_seconds = var.cluster_token_ttl_seconds
    cluster_token = var.cluster_token
  }
}

resource "null_resource" "join" {
  depends_on = [null_resource.setup_token]
  count      = var.node_count - 1 < 1 ? 0 : var.node_count - 1

  provisioner "local-exec" {
    command = "lxc exec ${lxd_container.microk8s-nodes[count.index + 1].name} -- sh -c \"sleep 10; /usr/local/bin/join.sh\""
  }
}

data "template_file" "join_token" {
  template = file("${path.module}/templates/join.sh")
  vars = {
    controller_name = "mk8s-node-${var.cluster_name}-0"
    cluster_token = var.cluster_token
  }
}