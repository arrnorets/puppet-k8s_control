class k8s_control::certs ( String $k8s_rootdir, Hash $tls_hash ) {

    $own_ca_key = $tls_hash["entities"]["ca"]["key"]
    $own_ca_crt = $tls_hash["entities"]["ca"]["cert"]
    $k8s_api_key = $tls_hash["entities"]["kubernetes"]["key"]
    $k8s_api_crt = $tls_hash["entities"]["kubernetes"]["cert"]

    $k8s_service_accounts_private_key = $tls_hash["entities"]["service-accounts"]["key"]
    $k8s_service_accounts_crt = $tls_hash["entities"]["service-accounts"]["cert"]

    file { "${k8s_rootdir}" :
        ensure => directory,
        mode => '0700',
        owner => root,
        group => root
    }
    file { "${k8s_rootdir}/k8s-api.key" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template("${k8s_api_key}")
    }
    file { "${k8s_rootdir}/k8s-api.crt" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => inline_template("${k8s_api_crt}")
    }
    file { "${k8s_rootdir}/own_ca.key" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template("${own_ca_key}")
    }
    file { "${k8s_rootdir}/own_ca.crt" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => inline_template("${own_ca_crt}")
    }

    file { "${k8s_rootdir}/service-accounts.key" :
        ensure => file,
        mode => '0600',
        owner => root,
        group => root,
        content => inline_template("${k8s_service_accounts_private_key}")
    }

    file { "${k8s_rootdir}/service-accounts.crt" :
        ensure => file,
        mode => '0644',
        owner => root,
        group => root,
        content => inline_template("${k8s_service_accounts_crt}")
    }

}

