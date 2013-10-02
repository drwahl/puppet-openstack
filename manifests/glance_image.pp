# this class will add images to glance

define openstack::glance_image (
    $source           = undef,
    $is_public        = true,
    $disk_format      = 'qcow2',
    $container_format = 'bare',
) {

    exec { "retrieve_${name}":
        command => "wget ${source} -O \"/var/lib/glance/${name}.img\"",
        unless  => "/opt/admin/openstack/glance_verify_image.sh \"${name}\"",
        notify  => Exec["add_image_${name}"],
        cwd     => '/var/lib/glance/'
    }

    exec { "add_image_${name}":
        command     => "/opt/admin/openstack/glance_add_image.sh ${is_public} ${disk_format} ${container_format} \"${name}\"",
        refreshonly => true,
        cwd         => '/var/lib/glance/',
    }

}
