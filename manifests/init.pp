# openstack
class openstack (
){

    package { 'openstack-utils':
        ensure => present
    }

    package { 'openstack-nova-common':
        ensure => present
    }

    package { 'avahi':
        ensure => present
    }

    package { 'avahi-libs':
        ensure => present
    }

    package { 'qpid-cpp-server':
        ensure => present
    }

    service { 'qpidd':
        ensure  => running,
        require => Package['qpid-cpp-server']
    }

    package { 'dbus':
        ensure => present
    }

    service { 'messagebus':
        ensure  => running,
        enabled => true,
        require => Package['dbus']
    }

    file { '/etc/qpidd.conf':
        ensure  => present,
        content => template('openstack/qpidd.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['qpid-cpp-server'],
        notify  => Service['qpidd']
    }

}
