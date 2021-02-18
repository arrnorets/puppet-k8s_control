class k8s_control::apiserver_config ( String $k8s_rootdir, Hash $k8s_api_cluster_hash, Hash $encryption_config_yaml_input ) {

    $k8s_api_binarypath = $k8s_api_cluster_hash["binarypath"]
    $k8s_api_advertise_address = $k8s_api_cluster_hash["apiservers_advertise"]["${hostname}"]["ip_address"]

    file { "${k8s_rootdir}/encryption-config.yaml":
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template( hash2yml($encryption_config_yaml_input) ),
        notify => Service[ "k8s-api" ]
    }

    $exec_start_string = create_k8s_api_exec_start( $k8s_api_binarypath, $k8s_api_advertise_address, $k8s_api_cluster_hash )

    file { "/etc/systemd/system/k8s-api.service" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => template("k8s_control/k8s-api.systemd.erb"),
    }

    exec { "systemd_reload_by_k8s_api":
        command => 'systemctl daemon-reload',
        path => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin" ],
        refreshonly => true,
        subscribe => File[ "/etc/systemd/system/k8s-api.service" ],
        notify => Service[ "k8s-api" ]
    }
}

