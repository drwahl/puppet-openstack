# this class will add images to glance

define openstack::glance_image (
    $source           = undef,
    $is_public        = true,
    $disk_format      = 'qcow2',
    $container_format = 'bare',
) {

    exec { "retrieve_${name}":
        command => "wget ${source} -O \"/var/lib/glance/${name}.img\"",
        unless  => "glance image-show \"${name}\" > /dev/null",
        notify  => Exec["add_image_${name}"],
        cwd     => '/var/lib/glance/'
    }

    exec { "add_image_${name}":
        command     => "glance image-create --is-public ${is_public} --disk-format ${disk_format} --container-format ${container_format} --name \"${name}\" < \"/var/lib/glance/${name}.img\"",
        refreshonly => true,
        cwd         => '/var/lib/glance/',
    }

}
