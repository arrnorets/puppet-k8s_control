class k8s_control {
    # /* Top hash */
    $hash_from_hiera = lookup('k8s_control_plane', { merge => 'deep' } )
    # /* END BLOCK */

    # /* Kubernetes config and certs root directory */
    $k8s_rootdir_array = $hash_from_hiera['rootdirs']

    file { $k8s_rootdir_array :
        ensure => directory,
        owner => root,
        group => root,
        mode => '0700',
    }

    $k8s_rootdir_value = $hash_from_hiera['vardir']

    # /* END BLOCK */ 

    # /* Certificates for authentication */
    $tls_credetials_hash = lookup('k8s_tls_certs', { merge => 'deep' })
    # /* END BLOCK */

    # /* API server parameters start here */
    $hash_from_hiera_api = $hash_from_hiera['apiserver']
    $k8s_api_pkg_name = $hash_from_hiera_api['pkg_name'] ? { undef => 'present', default => $hash_from_hiera_api['pkg_name'] }
    $k8s_api_pkg_version = $hash_from_hiera_api['pkg_version'] ? { undef => 'present', default => $hash_from_hiera_api['pkg_version'] }
    $k8s_api_hash_value = $hash_from_hiera_api['parameters'] ? { undef => 'false', default => $hash_from_hiera_api['parameters'] }
    $k8s_api_service_enable_value = $hash_from_hiera_api['enable'] ? { undef => false, default => $hash_from_hiera_api['enable'] }
    # /* END BLOCK */

    # /* Scheduler parameters start here */
    $hash_from_hiera_scheduler = $hash_from_hiera['scheduler']
    $k8s_scheduler_pkg_name = $hash_from_hiera_scheduler['pkg_name'] ? { undef => 'present', default => $hash_from_hiera_scheduler['pkg_name'] }
    $k8s_scheduler_pkg_version = $hash_from_hiera_scheduler['pkg_version'] ? { undef => 'present', default => $hash_from_hiera_scheduler['pkg_version'] }
    $k8s_scheduler_parameter_hash = $hash_from_hiera_scheduler['parameters'] ? { undef => 'false', default => $hash_from_hiera_scheduler['parameters'] }
    $k8s_scheduler_service_enable_value = $hash_from_hiera_scheduler['enable'] ? { undef => false, default => $hash_from_hiera_scheduler['enable'] }
    # /* END BLOCK */

    # /* Control manager  parameters start here */
    $hash_from_hiera_control_manager = $hash_from_hiera['control-manager']
    $k8s_control_manager_pkg_name = $hash_from_hiera_control_manager['pkg_name'] ? { undef => 'present', default => $hash_from_hiera_control_manager['pkg_name'] }
    $k8s_control_manager_pkg_version = $hash_from_hiera_control_manager['pkg_version'] ? { undef => 'present', default => $hash_from_hiera_control_manager['pkg_version'] }
    $k8s_control_manager_parameter_hash = $hash_from_hiera_control_manager['parameters'] ? { undef => 'false', default => $hash_from_hiera_control_manager['parameters'] }
    $k8s_control_manager_service_enable_value = $hash_from_hiera_control_manager['enable'] ? { undef => false, default => $hash_from_hiera_control_manager['enable'] }
    # /* END BLOCK */

    # /* Kubectl parameters start here */
    $hash_from_hiera_kubectl = $hash_from_hiera['kubectl']
    $k8s_kubectl_pkg_name = $hash_from_hiera_kubectl['pkg_name'] ? { undef => 'present', default => $hash_from_hiera_kubectl['pkg_name'] }
    $k8s_kubectl_pkg_version = $hash_from_hiera_kubectl['pkg_version'] ? { undef => 'present', default => $hash_from_hiera_kubectl['pkg_version'] }
    # /* END BLOCK */

    # /* encryption-config.yaml description */
    $k8s_encryption_config_yaml_input = lookup( 'k8s_encryption-config', { merge => 'first' } )
    # /* END BLOCK */

    # /* Kubeconfigs */
    $k8s_kubeconfigs_hash = lookup ( 'k8s_kubeconfigs', { merge => 'first' } )  
    # /* END BLOCK */ 

    class { "k8s_control::install" :
        api_pkg_name => $k8s_api_pkg_name,
        api_pkg_version => $k8s_api_pkg_version,
        scheduler_pkg_name => $k8s_scheduler_pkg_name,
        scheduler_pkg_version => $k8s_scheduler_pkg_version,
        control_manager_pkg_name => $k8s_control_manager_pkg_name,
        control_manager_pkg_version => $k8s_control_manager_pkg_version,
        kubectl_pkg_name => $k8s_kubectl_pkg_name,
        kubectl_pkg_version => $k8s_kubectl_pkg_version
    }

    class { "k8s_control::certs" :
        k8s_rootdir => $k8s_rootdir_value,
        tls_hash => $tls_credetials_hash
    }

    class { "k8s_control::apiserver_config" :
        k8s_rootdir => $k8s_rootdir_value,
        k8s_api_cluster_hash => $k8s_api_hash_value,
        encryption_config_yaml_input => $k8s_encryption_config_yaml_input
    }

    class { "k8s_control::control_manager_config" :
        control_manager_config_hash => $k8s_control_manager_parameter_hash,
        kubeconfigs_hash => $k8s_kubeconfigs_hash
    }

    class { "k8s_control::scheduler_config" :
        scheduler_config_hash => $k8s_scheduler_parameter_hash,
        kubeconfigs_hash => $k8s_kubeconfigs_hash
    }

    class { "k8s_control::service" :
        k8s_api_service_enable => $k8s_api_service_enable_value,
        k8s_control_manager_service_enable => $k8s_control_manager_service_enable_value,
        k8s_scheduler_service_enable => $k8s_scheduler_service_enable_value
    }

}

