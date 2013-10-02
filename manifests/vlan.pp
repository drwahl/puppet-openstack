# This class will add vlans to openstack.  This class should only be applied
# to the "network controller" (which might reside on the "controller" node).
#
# [range]
# Default: undef
# CIDR notation network range of IPs for VMs of this project.
#
# [vlan_tag]
# Default: undef
# Tag to apply to packets that come from this network range.
#
# [bridge]
# Default: undef
# Bridge used to route this network off of the host.
#
# [tenant]
# Default: undef
# ID of the tenant to assign this network to. To find the tenant ID, use the
# following command:
# keystone tenant-list
#
# [floating_ips_start]
# Default: undef
# The first address in the pool of floating IPs to be associated with this
# vlan.
#
# [floating_ips_end]
# Default: undef
# The last address in the pool of floating IPs to be associated with this vlan.
#
# [floating_ips_gateway]
# Default: undef
# The gateway or router for the pool of floating IPs to be associated with this
# vlan.
#
# [floating_ips_cidr]
# Default: undef
# CIDR notation (i.e. 172.20.1.1/24) of the network of floating IPs.
#
# [floating_ips_name]
# Default: default_floaters
# A friendly name to give to this set of floating IPs.  If the name matches an
# existing set of floating IPs, then this pool of floating IPs will *not* be
# created.
#
# [ext_network_name]
# Default: ext_net
# OpenStack human readable name for the external network
#
# [dns_nameserver]
# Default: 192.168.172.100
# DNS server to add to images for a given vlan.
#
# Example:
#
# openstack::vlan { 'net169':
#     range                => '172.16.169.0/24',
#     vlan_tag             => '169',
#     bridge               => 'br169',
#     tenant               => 'a421ae28356b4cc3a25e1429a0b02e98',
#     floating_ips_start   => 7.7.7.130,
#     floating_ips_end     => 7.7.7.150,
#     floating_ips_gateway => 7.7.7.1,
#     floating_ips_cidr    => 7.7.7.0/24
# }
#

define openstack::vlan (
    $range                = undef,
    $vlan_tag             = undef,
    $bridge               = undef,
    $tenant               = undef,
    $network_name         = 'default',
    $int_interface        = 'physnet1',
    $ext_interface        = 'physnet2',
    $floating_ips_start   = undef,
    $floating_ips_end     = undef,
    $floating_ips_gateway = undef,
    $floating_ips_cidr    = undef,
    $floating_ips_name    = 'default_floaters',
    $ext_network_name     = 'ext_net',
    $dns_nameserver       = '192.168.172.100'
) {

    exec { "create_vlan_${name}_for_tenant_${tenant}":
        command => "/opt/admin/openstack/vlan_create.sh ${tenant} ${network_name} ${int_interface} ${vlan_tag}",
        unless  => "/opt/admin/openstack/vlan_verify.sh ${network_name} ${tenant}"
    }

    exec { "create_subnet_${range}_for_tenant_${tenant}":
        command => "/opt/admin/openstack/subnet_create.sh ${tenant} ${network_name} ${range} ${name} ${dns_nameserver}",
        unless  => "/opt/admin/openstack/subnet_verify.sh ${name} ${tenant}",
        require => Exec["create_vlan_${name}_for_tenant_${tenant}"]
    }

    exec { "create_default_route_for_${name}_for_tenant_${tenant}":
        command => "/opt/admin/openstack/default_route_create.sh ${tenant} default_router_for_${name}",
        unless  => "/opt/admin/openstack/default_route_verify.sh default_router_for_${name} ${tenant}",
    }

    exec { "add_${name}_to_default_route_for_tenant_${tenant}":
        command => "/opt/admin/openstack/add_default_route_for_subnet.sh ${name} ${tenant}",
        unless  => "/opt/admin/openstack/verify_default_route_for_subnet.sh ${name}",
        require => [
            Exec["create_default_route_for_${name}_for_tenant_${tenant}"],
            Exec["create_vlan_${name}_for_tenant_${tenant}"],
            Exec["create_subnet_${range}_for_tenant_${tenant}"]
        ]
    }

#Note:
#The following commands need to be run as the admin, which should be in the
#environment for the root account.  Thus, there is no --tenant_id for this.
    exec { "create_external_network_${ext_network_name}_for_${name}_for_tenant_${tenant}":
        command => "/opt/admin/openstack/ext_net_create.sh ${ext_network_name} ${ext_interface}",
        unless  => "/opt/admin/openstack/ext_net_verify.sh ${ext_network_name}"
    }

    exec { "create_subnet_for_floating_ips_for_${name}_for_tenant_${tenant}":
        command => "/opt/admin/openstack/floating_ips_create.sh ${ext_network_name} ${floating_ips_start} ${floating_ips_end} ${floating_ips_gateway} ${floating_ips_cidr} ${floating_ips_name}",
        unless  => "/opt/admin/openstack/floating_ips_verify.sh ${floating_ips_name}",
        require => Exec["create_external_network_${ext_network_name}_for_${name}_for_tenant_${tenant}"]
    }

    exec { "set_router_gateway_towards_${ext_network_name}_for_${name}_for_tenant_${tenant}":
        command => "/opt/admin/openstack/router_gateway_set.sh default_router_for_${name} ${ext_network_name}",
        unless  => "/opt/admin/openstack/router_gateway_verify.sh default_router_for_${name}",
        require => [
            Exec["create_default_route_for_${name}_for_tenant_${tenant}"],
            Exec["create_subnet_for_floating_ips_for_${name}_for_tenant_${tenant}"],
            Exec["create_external_network_${ext_network_name}_for_${name}_for_tenant_${tenant}"]
        ]
    }
}
