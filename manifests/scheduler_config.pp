class k8s_control::scheduler_config ( Hash $scheduler_config_hash, Hash $kubeconfigs_hash ) {

    $k8s_scheduler_binarypath = $scheduler_config_hash["binarypath"]
    $scheduler_yamlconfig = $scheduler_config_hash["common"]["config"]
    $scheduler_kubeconfig = $scheduler_config_hash["conf"][$scheduler_yamlconfig]["clientConnection"]["kubeconfig"]

    file { "${scheduler_kubeconfig}" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template( hash2yml( $kubeconfigs_hash[ "${scheduler_kubeconfig}" ] ) )
    }

    file { "${scheduler_yamlconfig}" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template( hash2yml( $scheduler_config_hash["conf"][ "${scheduler_yamlconfig}" ] ) ) 
    }

    $exec_start_string = create_k8s_scheduler_exec_start( $k8s_scheduler_binarypath, $scheduler_config_hash )

    file { "/etc/systemd/system/k8s-scheduler.service" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => template("k8s_control/k8s-scheduler.systemd.erb")
    }

    exec { "systemd_reload_by_k8s_scheduler":
        command => 'systemctl daemon-reload',
        path => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin" ],
        refreshonly => true,
        subscribe => File[ "/etc/systemd/system/k8s-scheduler.service" ]
    }
}

