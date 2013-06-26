# openstack compute node (for hosting VMs)
class openstack::compute (
    $auth_host         = '127.0.0.1',
    $keystone_host     = 'localhost',
    $admin_user        = 'admin',
    $admin_password    = 'admin',
    $nova_user         = 'nova',
    $nova_password     = 'nova',
    $quantum_user      = 'quantum',
    $quantum_password  = 'quantum'
) {

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
        require => Package['openstack-quantum-openvswitch']
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

}
