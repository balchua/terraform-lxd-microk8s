# LXD Terraform with MicroK8s

This project bootstrap a MicroK8s cluster with LXD.  
_Only tested with local LXD_

## Use case

You can have a multi-node MicroK8s on your local machine using LXD (system container).

## Pre-requisite

* LXD installed locally
* terraform v0.13
* disabled ipv6 on lxd bridge

### Disable lxd IPv6

_Currently the joining of nodes with IPv6 doesnt work._
`lxc network set lxdbr0 ipv6.address none`