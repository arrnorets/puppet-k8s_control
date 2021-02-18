class k8s_control::install ( String $api_pkg_name, String $api_pkg_version,
  String $scheduler_pkg_name, String $scheduler_pkg_version,
  String $control_manager_pkg_name, String $control_manager_pkg_version,
  String $kubectl_pkg_name, String $kubectl_pkg_version ) {
    
    package { "${api_pkg_name}":
        ensure => $api_pkg_version,
    }

    package { "${scheduler_pkg_name}":
        ensure => $scheduler_pkg_version,
    }

    package { "${control_manager_pkg_name}":
        ensure => $control_manager_pkg_version,
    }

    package { "${kubectl_pkg_name}":
        ensure => $kubectl_pkg_version,
    }
}

