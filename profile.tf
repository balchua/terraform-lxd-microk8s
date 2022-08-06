resource "lxd_profile" "microk8s-profile" {
  name = "microk8s-profile-ext4"

  config = {
    "boot.autostart" = "true"
    "linux.kernel_modules" = "ip_vs,ip_vs_rr,ip_vs_wrr,ip_vs_sh,ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter"
    "raw.lxc" = <<-EOT
       lxc.apparmor.profile=unconfined
       lxc.mount.auto=proc:rw sys:rw cgroup:rw
       lxc.cgroup.devices.allow=a
       lxc.cap.drop=
       EOT

    "security.nesting" = "true"
    "security.privileged" = "true"
    "user.user-data" = <<-EOT
    #cloud-config

    # Install additional packages on first boot
    #
    # Default: none
    #
    # if packages are specified, this apt_update will be set to true
    #
    # packages may be supplied as a single package name or as a list
    # with the format [<package>, <version>] wherein the specifc
    # package version will be installed.
    packages:
    - bridge-utils

    snap:
        commands:
            00: snap install microk8s --channel=${var.microk8s_channel} --classic

    EOT
  }

  device {
    type = "disk"
    name = "aadisable"
    properties = {
      path: "/sys/module/nf_conntrack/parameters/hashsize"
      source: "/sys/module/nf_conntrack/parameters/hashsize"
    }
  }

  device {
    type = "disk"
    name = "aadisable2"
    properties = {
      path: "/dev/kmsg"
      source: "/dev/kmsg"
    }
  }  

  device {
    type = "disk"
    name = "aadisable3"
    properties = {
      path: "/sys/fs/bpf"
      source: "/sys/fs/bpf"
    }
  } 

  device {
    type = "disk"
    name = "aadisable4"
    properties = {
      path: "/proc/sys/net/netfilter/nf_conntrack_max"
      source: "/proc/sys/net/netfilter/nf_conntrack_max"
    }
  } 
}