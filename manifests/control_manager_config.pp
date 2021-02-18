class k8s_control::control_manager_config ( Hash $control_manager_config_hash, Hash $kubeconfigs_hash ) {

    $k8s_control_manager_binarypath = $control_manager_config_hash["binarypath"]
    $control_manager_kubeconfig = $control_manager_config_hash["common"]["kubeconfig"] 

    file { "${control_manager_kubeconfig}" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template( hash2yml( $kubeconfigs_hash[ "${control_manager_kubeconfig}" ] ) )
    }

    $exec_start_string = create_k8s_control_manager_exec_start( $k8s_control_manager_binarypath, $control_manager_config_hash )

    file { "/etc/systemd/system/k8s-controller-manager.service" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => template("k8s_control/k8s-controller-manager.systemd.erb")
    }

    exec { "systemd_reload_by_k8s_control_manager":
        command => 'systemctl daemon-reload',
        path => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin" ],
        refreshonly => true,
        subscribe => File[ "/etc/systemd/system/k8s-controller-manager.service" ]
    }
}

