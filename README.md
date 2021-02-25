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

You can have a multi-node MicroK8s on your workstation or laptop using LXD (system container).

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

* `source` - Where the terraform module is located.  Example values: `../` or `"git::https://github.com/balchua/terraform-lxd-microk8s?ref=main"`
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
root@test:~# lxc list
+------------------+---------+----------------------------+------+-----------+-----------+
|       NAME       |  STATE  |            IPV4            | IPV6 |   TYPE    | SNAPSHOTS |
+------------------+---------+----------------------------+------+-----------+-----------+
| mk8s-node-nemo-0 | RUNNING | 10.60.198.198 (eth0)       |      | CONTAINER | 0         |
|                  |         | 10.1.32.64 (vxlan.calico)  |      |           |           |
+------------------+---------+----------------------------+------+-----------+-----------+
| mk8s-node-nemo-1 | RUNNING | 10.60.198.234 (eth0)       |      | CONTAINER | 0         |
|                  |         | 10.1.53.192 (vxlan.calico) |      |           |           |
+------------------+---------+----------------------------+------+-----------+-----------+
| mk8s-node-nemo-2 | RUNNING | 10.60.198.250 (eth0)       |      | CONTAINER | 0         |
|                  |         | 10.1.227.64 (vxlan.calico) |      |           |           |
+------------------+---------+----------------------------+------+-----------+-----------+

```

Inspecting the container, one can go inside the system container.

```
$ lxc exec mk8s-node-nemo-0 -- bash
root@mk8s-node-nemo-0:~# 

```

## Kubernetes configuration

Kubernetes configuration is automatically placed into `/tmp/client.config`.  You can simply do `export KUBECONFIG=/tmp/client.config` to manage the cluster without going inside LXD container.

Checking with your local `kubectl`

```
kubectl get no -o wide
NAME               STATUS   ROLES    AGE     VERSION                     INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
mk8s-node-nemo-0   Ready    <none>   5m30s   v1.20.1-34+f62aca050e0b52   10.60.198.198   <none>        Ubuntu 20.04.1 LTS   5.4.0-51-generic   containerd://1.3.7
mk8s-node-nemo-2   Ready    <none>   115s    v1.20.1-34+f62aca050e0b52   10.60.198.250   <none>        Ubuntu 20.04.1 LTS   5.4.0-51-generic   containerd://1.3.7
mk8s-node-nemo-1   Ready    <none>   106s    v1.20.1-34+f62aca050e0b52   10.60.198.234   <none>        Ubuntu 20.04.1 LTS   5.4.0-51-generic   containerd://1.3.7
```

## Enabling addons

if you need to enable some addons, you need to choose one of the lxd container, for example `mk8s-node-nemo-0`.
Example below enables the `dns` addon.


```
root@test:~# lxc exec mk8s-node-nemo-0 -- microk8s enable dns
Enabling DNS
Applying manifest
serviceaccount/coredns created
configmap/coredns created
deployment.apps/coredns created
service/kube-dns created
clusterrole.rbac.authorization.k8s.io/coredns created
clusterrolebinding.rbac.authorization.k8s.io/coredns created
Restarting kubelet
Adding argument --cluster-domain to nodes.
Configuring node 10.60.198.198
Configuring node 10.60.198.234
Configuring node 10.60.198.250
Adding argument --cluster-dns to nodes.
Configuring node 10.60.198.198
Configuring node 10.60.198.234
Configuring node 10.60.198.250
Restarting nodes.
Configuring node 10.60.198.198
Configuring node 10.60.198.234
Configuring node 10.60.198.250
DNS is enabled
root@test:~# kubectl get pods -A -o wide
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE     IP              NODE               NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-847c8c99d-djz49   1/1     Running   0          10m     10.1.32.66      mk8s-node-nemo-0   <none>           <none>
kube-system   calico-node-frgzx                         1/1     Running   1          6m25s   10.60.198.250   mk8s-node-nemo-2   <none>           <none>
kube-system   coredns-86f78bb79c-ljlhp                  1/1     Running   0          97s     10.1.53.193     mk8s-node-nemo-1   <none>           <none>
kube-system   calico-node-mc87j                         1/1     Running   1          7m35s   10.60.198.198   mk8s-node-nemo-0   <none>           <none>
kube-system   calico-node-d62qq                         1/1     Running   1          6m25s   10.60.198.234   mk8s-node-nemo-1   <none>           <none>

``
