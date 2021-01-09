# LXD Terraform with MicroK8s

A terraform module to bootstrap a MicroK8s cluster with LXD.

_What is LXD?_
LXD is a next generation system container manager. It offers a user experience similar to virtual machines but using Linux containers instead.

More information [here](https://linuxcontainers.org/lxd/introduction/)

_Whats is Terraform?_
Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

This module uses the awesome project [Terraform provider lxd](https://github.com/terraform-lxd/terraform-provider-lxd).
The terraform lxd provider allows one to bootstrap an lxd container using Terraform.  Great combo!


_Only tested with local LXD_

## Use case

You can have a multi-node MicroK8s on your local machine using LXD (system container).

## Pre-requisite

* LXD installed locally
* terraform v0.14.0
* disabled ipv6 on lxd bridge

### Disable lxd IPv6

_Currently the joining of nodes with IPv6 doesnt work._
`lxc network set lxdbr0 ipv6.address none`

## Usage

* Initialize your project with terraform
  
  `terraform init`

* Create a `module` file

```
module "microk8s" {
  source                     = "../"
  node_count                 = "3"
  microk8s_channel           = "1.20/edge"
  cluster_token              = "PoiuyTrewQasdfghjklMnbvcxz123409"
  cluster_token_ttl_seconds  = 3600
  cluster_name               = "nemo"
}
```

Parameter descriptions:

* `source` - Where the terraform module is located.  Example values: `../` or `"git::https://github.com/balchua/lxd-microk8s?ref=v0.1.0"`
* `node_count` - Specify how many lxd containers. Default: `3`
* `microk8s_channel` - Specify the MicroK8s channel you want to use. Default `1.20/stable`
* `cluster_token` - The token to use to join several nodes together, forming a cluster.  No default
* `cluster_token_ttl_seconds` - The lifetime in seconds of the cluster token.  Default `3600` seconds
* `cluster_name` - Arbitrary name of the nodes.  In the example above, the node name will be `mk8s-node-nemo-0`

## Boostrapping a cluster

After setting up the terraform recipe above, you can now start to provision your MicroK8s cluster using LXD.

```
$ terraform apply

. . .


  # module.microk8s.null_resource.get_kubeconfig will be created
  + resource "null_resource" "get_kubeconfig" {
      + id = (known after apply)
    }

  # module.microk8s.null_resource.join[0] will be created
  + resource "null_resource" "join" {
      + id = (known after apply)
    }

  # module.microk8s.null_resource.join[1] will be created
  + resource "null_resource" "join" {
      + id = (known after apply)
    }

  # module.microk8s.null_resource.setup_token will be created
  + resource "null_resource" "setup_token" {
      + id = (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.microk8s.lxd_profile.microk8s-profile: Creating...
module.microk8s.lxd_profile.microk8s-profile: Creation complete after 0s [id=microk8s-profile-ext4]
module.microk8s.lxd_container.microk8s-nodes[2]: Creating...
module.microk8s.lxd_container.microk8s-nodes[1]: Creating...
module.microk8s.lxd_container.microk8s-nodes[0]: Creating...
. . .  
```

While it is provisioning, you can see the lxc containers.

```
$ lxc list
+--------------------+---------+-----------------------+------+-----------+-----------+
|        NAME        |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+--------------------+---------+-----------------------+------+-----------+-----------+
| mk8s-node-nemo-0   | RUNNING | 10.124.129.57 (eth0)  |      | CONTAINER | 0         |
+--------------------+---------+-----------------------+------+-----------+-----------+
| mk8s-node-nemo-1   | RUNNING | 10.124.129.249 (eth0) |      | CONTAINER | 0         |
+--------------------+---------+-----------------------+------+-----------+-----------+
| mk8s-node-nemo-2   | RUNNING | 10.124.129.168 (eth0) |      | CONTAINER | 0         |
+--------------------+---------+-----------------------+------+-----------+-----------+

```

Inspecting the container, one can go inside the system container.

```
$ lxc exec mk8s-node-nemo-0 -- bash
root@mk8s-node-nemo-0:~# 

```

## Kubernetes configuration

Kubernetes configuration is automatically placed into `/tmp/client.config`.  You can simply do `export KUBECONFIG=/tmp/client.config` to manage the cluster without going inside LXD container.

