# openstack compute node (for hosting VMs)
class openstack::compute (
    $auth_host                = '127.0.0.1',
    $keystone_host            = 'localhost',
    $admin_tenant_name        = 'admin',
    $admin_user               = 'admin',
    $admin_password           = 'admin',
    $nova_user                = 'nova',
    $nova_password            = 'nova',
    $quantum_user             = 'quantum',
    $quantum_password         = 'quantum',
    $metadata_shared_password = 'password',
    $vlan_interface           = 'eth1'
) {

    class { 'openstack::repo': }

    package { 'qemu-kvm':
        ensure => present
    }

    package { 'openstack-nova-compute':
        ensure => present
    }

    service { 'openstack-nova-compute':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        require   => Package['openstack-nova-compute']
    }

    file { '/etc/nova/nova.conf':
        ensure  => present,
        content => template('openstack/nova/nova.conf_compute.erb'),
        owner   => 'root',
        group   => 'nova',
        mode    => '0640',
        require => Package['openstack-nova-compute'],
        notify  => Service['openstack-nova-compute']
    }

    file { '/etc/nova/api-paste.ini':
        ensure  => present,
        content => template('openstack/nova/api-paste.ini_compute.erb'),
        owner   => 'root',
        group   => 'nova',
        mode    => '0640',
        require => Package['openstack-nova-compute'],
        notify  => Service['openstack-nova-compute']
    }

    package { 'openvswitch':
        ensure => present
    }

    service { 'openvswitch':
        ensure  => running,
        enable  => true,
        require => Package['openvswitch']
    }

    package { 'openstack-quantum-openvswitch':
        ensure => present
    }

    service { 'quantum-openvswitch-agent':
        ensure  => running,
        enable  => true,
        require => [
            Package['openstack-quantum-openvswitch'],
        ]
    }

    service { 'quantum-ovs-cleanup':
        ensure  => undef,
        enable  => true,
        require => Package['openstack-quantum-openvswitch']
    }

    file { '/etc/quantum/quantum.conf':
        ensure  => present,
        content => template('openstack/quantum/quantum.conf.erb'),
        owner   => 'root',
        group   => 'quantum',
        mode    => '0640',
        require => Package['openstack-quantum-openvswitch'],
        notify  => Service['openvswitch']
    }

    file { '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini':
        ensure  => present,
        content => template('openstack/quantum/ovs_quantum_plugin.ini_compute.erb'),
        owner   => 'root',
        group   => 'quantum',
        mode    => '0640',
        require => Package['openstack-quantum-openvswitch'],
        notify  => Service['openvswitch']
    }

    file { '/root/.openstack.rc':
        ensure  => present,
        content => template('openstack/openstack.rc.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }

    file { '/root/.bashrc':
        ensure  => present,
        content => template('openstack/bashrc.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }

    exec { 'load_8021q_module':
        command => 'modprobe 8021q',
        unless  => 'lsmod | grep -q ^8021q'
    }

    exec { 'enable_ipv4_forward' :
        command => 'sysctl net.ipv4.ip_forward=1',
        unless  => 'sysctl net.ipv4.ip_forward | cut -d\' \' -f 3 | grep -q 1',
        require => Exec['load_8021q_module']
    }

    exec { 'add_ovs_internal_bridge':
        command => 'ovs-vsctl add-br br-int',
        unless  => 'ovs-vsctl br-exists br-int',
        require => Package['openvswitch']
    }

    exec { 'add_ovs_br_eth1':
        command => 'ovs-vsctl add-br br-eth1',
        unless  => 'ovs-vsctl br-exists br-eth1',
        notify  => Exec['bridge_ovs_eth1_to_br_eth1'],
        require => Package['openvswitch']
    }

    exec { 'bridge_ovs_eth1_to_br_eth1':
        command     => 'ovs-vsctl port-add br-eth1 eth1',
        refreshonly => true,
        require     => Exec['add_ovs_br_eth1']
    }

    service { 'quantum-metadata-agent':
        ensure  => running,
        enable  => true,
        require => Package['openstack-quantum-openvswitch']
    }

    file { '/etc/quantum/metadata_agent.ini':
        ensure  => present,
        content => template('openstack/quantum/metadata_agent.ini.erb'),
        owner   => 'root',
        group   => 'quantum',
        mode    => '0640',
        require => Package['openstack-quantum-openvswitch'],
        notify  => Service['quantum-metadata-agent']
    }

}
