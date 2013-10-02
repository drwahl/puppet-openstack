# Setup/configure an OpenStack control node. The control node provides:
# - Queues (with qpid)
# - Keystone (Identity services)
# - Glance
# - Nova (without compute)
# - Cinder
# - Quantum Server (with OpenvSwitch plugin)
# - Dashboard (with Horizon)
#
# note: service account password are expected to be == to the name of the user
# for the service account.  this is a "bug" in the "--init" portion of the
# openstack-db script, which is used to initiailize the mysql database for use
# by the service.
#
# This module used the following link as a guide:
# http://docs.openstack.org/grizzly/basic-install/yum/content/basic-install_controller.html
#
# Example:
# class { 'openstack::control': }
#
class openstack::control (
    $enable                   = true,
    $auth_host                = '127.0.0.1',
    $region                   = 'RegionOne',
    $admin_user               = 'admin',
    $admin_password           = 'admin',
    $admin_tenant_name        = 'admin',
    $keystone_db              = 'keystone',
    $keystone_user            = 'keystone',
    $keystone_password        = 'keystone',
    $glance_user              = 'glance',
    $glance_password          = 'glance',
    $nova_user                = 'nova',
    $nova_password            = 'nova',
    $quantum_user             = 'quantum',
    $quantum_password         = 'quantum',
    $metadata_shared_password = 'password',
    $cinder_user              = 'cinder',
    $cinder_password          = 'cinder',
    $ec2_user                 = 'ec2',
    $ec2_password             = 'ec2',
    $swift_user               = 'swift',
    $swift_password           = 'swift',
    $nfs_shares               = ['nfs.example.com:/vm_storage01'],
    $nfs_shares_path          = '/var/lib/cinder/nfs',
    $int_network_interface    = 'eth1',
    $ext_network_interface    = 'eth2'
){

    class { 'openstack::repo': }

    package { 'httpd':
        ensure => present
    }

    service { 'httpd':
        ensure    => running,
        hasstatus => true,
        require   => Package['httpd']
    }

    package { 'qpid-cpp-server':
        ensure => present,
    }

    service { 'qpidd':
        ensure    => running,
        require   => Package['qpid-cpp-server'],
        hasstatus => true,
        subscribe => File['/etc/qpidd.conf']
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

    file { '/root/.bashrc':
        ensure  => present,
        content => template('openstack/bashrc.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }

    file { '/opt/.openstack.rc':
        ensure  => present,
        content => template('openstack/openstack.rc.erb'),
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0644'
    }

    file { '/root/.openstack.rc':
        ensure  => present,
        content => template('openstack/openstack.rc.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }

#configure glance
    package { 'openstack-glance':
        ensure => present
    }

    service { 'openstack-glance-api':
        ensure    => running,
        hasstatus => true,
        require   => Package['openstack-glance'],
        subscribe => File[
            '/etc/glance/glance-api-paste.ini',
            '/etc/glance/glance-api.conf',
            '/etc/glance/glance-cache.conf',
            '/etc/glance/glance-registry-paste.ini',
            '/etc/glance/glance-registry.conf',
            '/etc/glance/glance-scrubber.conf',
            '/etc/glance/policy.json',
            '/etc/glance/schema-image.json'
        ],
        notify    => Service['openstack-glance-registry']
    }

    service { 'openstack-glance-registry':
        ensure    => running,
        require   => Package['openstack-glance'],
        hasstatus => true,
        subscribe => File[
            '/etc/glance/glance-api-paste.ini',
            '/etc/glance/glance-api.conf',
            '/etc/glance/glance-cache.conf',
            '/etc/glance/glance-registry-paste.ini',
            '/etc/glance/glance-registry.conf',
            '/etc/glance/glance-scrubber.conf',
            '/etc/glance/policy.json',
            '/etc/glance/schema-image.json'
        ],
    }

    file { '/etc/glance/glance-api-paste.ini':
        ensure  => present,
        content => template('openstack/glance/glance-api-paste.ini.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/glance-api.conf':
        ensure  => present,
        content => template('openstack/glance/glance-api.conf.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/glance-cache.conf':
        ensure  => present,
        content => template('openstack/glance/glance-cache.conf.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/glance-registry-paste.ini':
        ensure  => present,
        content => template('openstack/glance/glance-registry-paste.ini.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/glance-registry.conf':
        ensure  => present,
        content => template('openstack/glance/glance-registry.conf.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/glance-scrubber.conf':
        ensure  => present,
        content => template('openstack/glance/glance-scrubber.conf.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/policy.json':
        ensure  => present,
        content => template('openstack/glance/policy.json.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    file { '/etc/glance/schema-image.json':
        ensure  => present,
        content => template('openstack/glance/schema-image.json.erb'),
        owner   => 'root',
        group   => 'glance',
        mode    => '0640',
        require => Package['openstack-glance'],
        notify  => [
            Service['openstack-glance-api'],
            Service['openstack-glance-registry']
        ]
    }

    exec { 'init_glance_db':
        command => 'openstack-db -r \'\' -y --init --service glance',
        unless  => 'mysql -u root -e \'SHOW TABLES IN glance\'',
        notify  => Exec['set_privs_on_glance_db_at_localhost'],
        require => [
            File['/etc/glance/glance-api.conf'],
            Exec['init_keystone_db']
        ]
    }

    exec { 'set_privs_on_glance_db_at_localhost':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON glance.* TO \'${glance_user}\'@\'localhost\' IDENTIFIED BY \'${glance_password}\'\"",
        unless      => "mysql -u ${glance_user} -p${glance_password} -e \'SHOW DATABASES\'",
        refreshonly => true,
        notify      => Exec['set_privs_on_glance_db_at_remote_host'],
        subscribe   => Exec['init_glance_db']
    }

    exec { 'set_privs_on_glance_db_at_remote_host':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON glance.* TO \'${glance_user}\'@\'%\' IDENTIFIED BY \'${glance_password}\'\"",
        refreshonly => true,
        subscribe   => Exec['set_privs_on_glance_db_at_localhost']
    }

#nova configuration (without nova-compute)
    package { 'openstack-nova-api':
        ensure => present
    }

    package { 'novnc':
        ensure => present
    }

    package { 'genisoimage':
        ensure => present
    }

    service { 'openstack-nova-api':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-nova-api'],
        hasstatus => true,
        subscribe => File[
            '/etc/nova/api-paste.ini',
            '/etc/nova/nova.conf'
        ],
        notify    => Service[
            'openstack-nova-cert',
            'openstack-nova-consoleauth',
            'openstack-nova-scheduler',
            'openstack-nova-conductor',
            'openstack-nova-novncproxy'
        ]
    }

    file { '/etc/nova/api-paste.ini':
        ensure  => present,
        content => template('openstack/nova/api-paste.ini.erb'),
        owner   => 'root',
        group   => 'nova',
        mode    => '0640',
        require => Package['openstack-nova-api']
    }

    file { '/etc/nova/nova.conf':
        ensure  => present,
        content => template('openstack/nova/nova.conf.erb'),
        owner   => 'root',
        group   => 'nova',
        mode    => '0640',
        require => Package['openstack-nova-api']
    }

    package { 'openstack-nova-scheduler':
        ensure => present
    }

    service { 'openstack-nova-scheduler':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        subscribe => Service['openstack-nova-api']
    }

    package { 'openstack-nova-cert':
        ensure => present
    }

    service { 'openstack-nova-cert':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        subscribe => Service['openstack-nova-cert']
    }

    package { 'openstack-nova-console':
        ensure => present
    }

    service { 'openstack-nova-console':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        require   => Package['openstack-nova-console'],
        subscribe => Service['openstack-nova-api']
    }

    service { 'openstack-nova-consoleauth':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-nova-console'],
        hasstatus => true,
        subscribe => Service['openstack-nova-api']
    }

    package { 'openstack-nova-conductor':
        ensure => present
    }

    service { 'openstack-nova-conductor':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        subscribe => Service['openstack-nova-api']
    }

    package { 'openstack-nova-novncproxy':
        ensure => present
    }

    service { 'openstack-nova-novncproxy':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        subscribe => Service['openstack-nova-api']
    }

    exec { 'init_nova_db':
        command => 'openstack-db -r \'\' -y --init --service nova',
        unless  => 'mysql -u root -e \'SHOW TABLES IN nova\'',
        notify  => Exec['set_privs_on_nova_db_at_localhost'],
        require => [
            File['/etc/nova/nova.conf'],
            Exec['init_keystone_db'],
            File['/etc/nova/api-paste.ini']
        ]
    }

    exec { 'set_privs_on_nova_db_at_localhost':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON nova.* TO \'${nova_user}\'@\'localhost\' IDENTIFIED BY \'${nova_password}\'\"",
        unless      => "mysql -u ${nova_user} -p${nova_password} -e \'SHOW DATABASES\'",
        refreshonly => true,
        notify      => Exec['set_privs_on_nova_db_at_remote_host'],
        subscribe   => Exec['init_nova_db']
    }

    exec { 'set_privs_on_nova_db_at_remote_host':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON nova.* TO \'${nova_user}\'@\'%\' IDENTIFIED BY \'${nova_password}\'\"",
        refreshonly => true,
        subscribe   => Exec['set_privs_on_nova_db_at_localhost']
    }

    file { '/usr/local/bin/openstack':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0655'
    }

#dashboard configuration
    package { 'openstack-dashboard':
        ensure => present
    }

    package { 'python-django-horizon':
        ensure => present
    }

    file { '/etc/openstack-dashboard/local_settings':
        ensure  => present,
        content => template('openstack/local_settings.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['openstack-dashboard']
    }

    file { '/etc/httpd/conf.d/openstack-dashboard.conf':
        ensure  => present,
        content => template('openstack/openstack-dashboard.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['httpd'],
        notify  => Service['httpd']
    }

#keystone configuration
    #from https://answers.launchpad.net/keystone/+question/229027
    cron { 'trim_keystone_tokens':
        ensure  => present,
        command => 'mysql -u root keystone -e \'DELETE FROM token WHERE NOT DATE_SUB(CURDATE(),INTERVAL 1 DAY) <= expires;\'',
        user    => 'root',
        minute  => 0,
        hour    => 0,
    }

    package { 'openstack-keystone':
        ensure => present
    }

    service { 'openstack-keystone':
        ensure    => running,
        require   => Package['openstack-keystone'],
        hasstatus => true,
        subscribe => File['/etc/keystone/keystone.conf']
    }

    file { '/etc/keystone/keystone.conf':
        ensure  => present,
        content => template('openstack/keystone.conf.erb'),
        owner   => 'root',
        group   => 'keystone',
        mode    => '0640',
        require => Package['openstack-keystone'],
        notify  => Service['openstack-keystone']
    }

    file { '/usr/local/bin/openstack/populate_keystone_db.sh':
        ensure  => present,
        content => template('openstack/populate_keystone_db.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0655',
        require => File['/usr/local/bin/openstack']
    }

    exec { 'create_keystone_pki':
        command => 'keystone-manage pki_setup',
        creates => '/etc/keystone/ssl/private/signing_key.pem',
        path    => ['/usr/bin'],
        require => Package['openstack-keystone'],
        notify  => Exec['fix_pki_perms']
    }

    exec { 'fix_pki_perms':
        command     => 'chown -R keystone:keystone /etc/keystone/ssl',
        refreshonly => true,
        subscribe   => Exec['create_keystone_pki']
    }

    exec { 'init_keystone_db':
        command   => 'openstack-db -r \'\' -y --init --service keystone',
        unless    => 'mysql -u root -e \'SHOW TABLES IN keystone\'',
        subscribe => Exec['create_keystone_pki'],
        require   => [
            File['/etc/keystone/keystone.conf'],
            Exec['create_keystone_pki']
        ],
        notify    => [
            Exec['set_privs_on_keystone_db_at_localhost'],
            Exec['set_privs_on_keystone_db_at_remote_host']
        ]
    }

    exec { 'set_privs_on_keystone_db_at_localhost':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON keystone.* TO \'${keystone_user}\'@\'localhost\' IDENTIFIED BY \'${keystone_password}\'\"",
        unless      => "mysql -u ${keystone_user} -p${keystone_password} -e \'SHOW DATABASES\'",
        refreshonly => true,
        notify      => Exec['set_privs_on_keystone_db_at_remote_host'],
        subscribe   => Exec['init_keystone_db']
    }

    exec { 'set_privs_on_keystone_db_at_remote_host':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON keystone.* TO \'${keystone_user}\'@\'%\' IDENTIFIED BY \'${keystone_password}\'\"",
        refreshonly => true,
        notify      => Exec['populate_keystone_db'],
        subscribe   => Exec['set_privs_on_keystone_db_at_localhost']
    }

    exec { 'populate_keystone_db':
        command     => '/usr/local/bin/openstack/populate_keystone_db.sh',
        refreshonly => true,
        require     => [
            File['/usr/local/bin/openstack/populate_keystone_db.sh'],
            Service['openstack-keystone'],
            Exec['set_privs_on_keystone_db_at_localhost']
        ],
        subscribe   => Exec['set_privs_on_keystone_db_at_remote_host']
    }


#cinder configuration
    package { 'openstack-cinder':
        ensure => present
    }

    service { 'openstack-cinder-api':
        ensure    => running,
        hasstatus => true,
        require   => [
            Package['openstack-cinder'],
            Exec['init_cinder_db']
        ]
    }

    service { 'openstack-cinder-scheduler':
        ensure    => running,
        hasstatus => true,
        require   => [
            Package['openstack-cinder'],
            Exec['init_cinder_db']
        ]
    }

    service { 'openstack-cinder-volume':
        ensure    => running,
        hasstatus => true,
        require   => [
            Package['openstack-cinder'],
            File['/etc/cinder/shares.txt'],
            Exec['init_cinder_db']
        ]
    }

    file { $nfs_shares_path :
        ensure  => directory,
        owner   => 'root',
        group   => 'cinder',
        mode    => '0770',
        require => Package['openstack-cinder']
    }

    file { '/etc/cinder/cinder.conf':
        ensure  => present,
        content => template('openstack/cinder/cinder.conf.erb'),
        owner   => 'root',
        group   => 'cinder',
        mode    => '0640',
        require => Package['openstack-cinder'],
        notify  => [
            Service['openstack-cinder-scheduler'],
            Service['openstack-cinder-api'],
            Service['openstack-cinder-volume']
        ]
    }

    file { '/etc/cinder/api-paste.ini':
        ensure  => present,
        content => template('openstack/cinder/api-paste.ini.erb'),
        owner   => 'root',
        group   => 'cinder',
        mode    => '0640',
        require => Package['openstack-cinder'],
        notify  => [
            Service['openstack-cinder-scheduler'],
            Service['openstack-cinder-api'],
            Service['openstack-cinder-volume']
        ]
    }

    file { '/etc/cinder/shares.txt':
        ensure  => present,
        content => template('openstack/cinder/shares.txt.erb'),
        owner   => 'root',
        group   => 'cinder',
        mode    => '0640',
        require => [
            Package['openstack-cinder'],
            File[$nfs_shares_path]
        ],
        notify  => [
            Service['openstack-cinder-scheduler'],
            Service['openstack-cinder-api'],
            Service['openstack-cinder-volume']
        ]
    }

    exec { 'init_cinder_db':
        command => 'openstack-db -r \'\' -y --init --service cinder 2>/dev/null ; cinder-manage db sync',
        unless  => 'mysql -u root -e \'SHOW TABLES IN cinder\'',
        notify  => Exec['set_privs_on_cinder_db_at_localhost'],
        require => [
            Exec['init_keystone_db'],
            File['/etc/cinder/api-paste.ini']
        ]
    }

    exec { 'set_privs_on_cinder_db_at_localhost':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON cinder.* TO \'${cinder_user}\'@\'localhost\' IDENTIFIED BY \'${cinder_password}\'\"",
        unless      => "mysql -u ${cinder_user} -p${cinder_password} -e \'SHOW DATABASES\'",
        refreshonly => true,
        notify      => Exec['set_privs_on_cinder_db_at_remote_host'],
        subscribe   => Exec['init_glance_db']
    }

    exec { 'set_privs_on_cinder_db_at_remote_host':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON cinder.* TO \'${cinder_user}\'@\'%\' IDENTIFIED BY \'${cinder_password}\'\"",
        refreshonly => true,
        subscribe   => Exec['set_privs_on_cinder_db_at_localhost']
    }

#quantum configuration
    package { 'openstack-quantum':
        ensure => present
    }

    package { 'openstack-quantum-openvswitch':
        ensure  => present,
        require => Package['openstack-quantum']
    }

    service { 'quantum-server':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-quantum'],
        subscribe => [
            File['/etc/quantum/plugin.ini'],
            File['/etc/quantum/quantum.conf'],
            File['/etc/quantum/api-paste.ini'],
            File['/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini']
        ]
    }

    package { 'openvswitch':
        ensure => present
    }

    service { 'openvswitch':
        ensure  => running,
        enable  => true,
        require => Package['openvswitch']
    }

    service { 'quantum-openvswitch-agent':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-quantum'],
        subscribe => File['/etc/quantum/api-paste.ini']
    }

    service { 'quantum-dhcp-agent':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-quantum'],
        subscribe => File['/etc/quantum/dhcp_agent.ini']
    }

    service { 'quantum-l3-agent':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-quantum'],
        subscribe => File['/etc/quantum/l3_agent.ini']
    }

    service { 'quantum-lbaas-agent':
        ensure    => undef,
        enable    => true,
        require   => Package['openstack-quantum'],
        subscribe => File['/etc/quantum/lbaas_agent.ini']
    }

    service { 'quantum-metadata-agent':
        ensure    => running,
        enable    => true,
        require   => Package['openstack-quantum'],
        subscribe => File['/etc/quantum/metadata_agent.ini']
    }

    file { '/etc/quantum/dhcp_agent.ini':
        ensure  => present,
        require => Package['openstack-quantum'],
        content => template('openstack/quantum/dhcp_agent.ini.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['quantum-dhcp-agent']
    }

    file { '/etc/quantum/l3_agent.ini':
        ensure  => present,
        require => Package['openstack-quantum'],
        content => template('openstack/quantum/l3_agent.ini.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['quantum-l3-agent']
    }

    file { '/etc/quantum/lbaas_agent.ini':
        ensure  => present,
        require => Package['openstack-quantum'],
        content => template('openstack/quantum/lbaas_agent.ini.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['quantum-l3-agent']
    }

    file { '/etc/quantum/api-paste.ini':
        ensure  => present,
        require => Package['openstack-quantum'],
        content => template('openstack/quantum/api-paste.ini.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['quantum-server']
    }

    file { '/etc/quantum/quantum.conf':
        ensure  => present,
        require => Package['openstack-quantum'],
        content => template('openstack/quantum/quantum.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['quantum-server']
    }

    file { '/etc/quantum/metadata_agent.ini':
        ensure  => present,
        require => Package['openstack-quantum'],
        content => template('openstack/quantum/metadata_agent.ini.erb'),
        owner   => 'root',
        group   => 'quantum',
        mode    => '0640',
        notify  => Service['quantum-server']
    }

    file { '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini':
        ensure  => present,
        require => Package['openstack-quantum-openvswitch'],
        content => template('openstack/quantum/ovs_quantum_plugin.ini.erb'),
        owner   => 'root',
        group   => 'quantum',
        mode    => '0640',
        notify  => Service['quantum-server']
    }

    file { '/etc/quantum/plugin.ini':
        ensure => link,
        target => '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini',
        notify => Service['quantum-server']
    }

    exec { 'init_quantum_db':
        command => 'mysql -u root -e \'CREATE DATABASE quantum\'',
        unless  => 'mysql -u root -e \'SHOW TABLES IN quantum\'',
        notify  => Exec['set_privs_on_quantum_db_at_localhost'],
        require => Exec['init_keystone_db']
    }

    exec { 'set_privs_on_quantum_db_at_localhost':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON quantum.* TO \'${quantum_user}\'@\'localhost\' IDENTIFIED BY \'${quantum_password}\'\"",
        refreshonly => true,
        notify      => Exec['set_privs_on_quantum_db_at_remote_host'],
        subscribe   => Exec['init_quantum_db']
    }

    exec { 'set_privs_on_quantum_db_at_remote_host':
        command     => "mysql -u root -e \"GRANT ALL PRIVILEGES ON quantum.* TO \'${quantum_user}\'@\'%\' IDENTIFIED BY \'${quantum_password}\'\"",
        refreshonly => true,
        subscribe   => Exec['set_privs_on_quantum_db_at_localhost']
    }

#networking stuff
    exec { 'add_ovs_internal_bridge':
        command => 'ovs-vsctl add-br br-int',
        unless  => 'ovs-vsctl br-exists br-int',
        require => File['/etc/quantum/plugin.ini']
    }

    exec { 'add_ovs_external_bridge':
        command => 'ovs-vsctl add-br br-ex',
        unless  => 'ovs-vsctl br-exists br-ex',
        notify  => Exec["connect_ovs_bridge_to_${ext_network_interface}"],
    }

    exec { "connect_ovs_bridge_to_${ext_network_interface}":
        command     => "ovs-vsctl add-port br-${ext_network_interface} br-ex",
        refreshonly => true,
        subscribe   => Exec['add_ovs_external_bridge'],
    }

#some files to make managing vlans through puppet easier
    file { '/opt/admin/openstack':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755'
    }

    file { '/opt/admin/openstack/add_default_route_for_subnet.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/add_default_route_for_subnet.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/default_route_create.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/default_route_create.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/default_route_verify.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/default_route_verify.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/ext_net_create.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/ext_net_create.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/ext_net_verify.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/ext_net_verify.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/floating_ips_create.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/floating_ips_create.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/floating_ips_verify.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/floating_ips_verify.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/router_gateway_set.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/router_gateway_set.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/router_gateway_verify.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/router_gateway_verify.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/subnet_create.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/subnet_create.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/subnet_verify.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/subnet_verify.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/verify_default_route_for_subnet.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/verify_default_route_for_subnet.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/vlan_create.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/vlan_create.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/vlan_verify.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/vlan_verify.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/glance_add_image.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/glance_add_image.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

    file { '/opt/admin/openstack/glance_verify_image.sh':
        ensure  => present,
        content => template('openstack/admin_scripts/glance_verify_image.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/opt/admin/openstack']
    }

}
