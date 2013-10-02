# setup OpenStack repo to install OpenStack
class openstack::repo {

    yumrepo { 'fedora-openstack-grizzly':
        baseurl  => 'http://repos.fedorapeople.org/repos/openstack/openstack-grizzly/epel-6',
        descr    => 'OpenStack Grizzly repo',
        enabled  => 1,
        gpgcheck => 0,
    }

}
