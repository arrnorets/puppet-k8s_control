class k8s_control::service ( Boolean $k8s_api_service_enable, Boolean $k8s_control_manager_service_enable, Boolean $k8s_scheduler_service_enable  ) {
    service { "k8s-api" :
        ensure => $k8s_api_service_enable,
        enable => $k8s_api_service_enable,
        require => Class[ "k8s_control::install" ],
    }

    service { "k8s-controller-manager" :
        ensure => $k8s_control_manager_service_enable,
        enable => $k8s_control_manager_service_enable,
        require => Class[ "k8s_control::install" ],
    }

    service { "k8s-scheduler" :
        ensure => $k8s_scheduler_service_enable,
        enable => $k8s_scheduler_service_enable,
        require => Class[ "k8s_control::install" ],
    }
}

