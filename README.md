# Table of contents
1. [Common purpose](#1-common-purpose)
2. [Compatibility](#2-compatibility)
3. [Installation](#3-installation)
4. [Config example in Hiera and result files](#4-config-example-in-hiera-and-result-files)


# 1. Common purpose
This is a module that installs and configures apiserver, controller-manager and scheduler - Kubernetes components that are required for control plane node in a cluster. In the end you will receive a server that is a part of Kubernetes cluster's control plane. See https://github.com/kelseyhightower/kubernetes-the-hard-way chapter 08 for detailed explanation.

Inspired by https://github.com/kelseyhightower/kubernetes-the-hard-way .

# 2. Compatibility
This module was tested on CentOS 7.

# 3. Installation
```yaml
mod 'k8s_workernode',
    :git => 'https://github.com/arrnorets/puppet-k8s_control.git',
    :ref => 'main'
```

# 4. Config example in Hiera and result files
This module follows the concept of so called "XaaH in Puppet". The principles are described [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/puppet-modules-organization/) and [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/3-hashes-in-hiera/).


Here is the example of config in Hiera:
```yaml

# First of all you have to generate at least CA and Kubernetes key-cert pairs in order to configure authentication of API server against ETCD and against other management components. 
# Kubernetes key-cert pair will be used as K8s API TLS credentials. See more deatils on https://github.com/kelseyhightower/kubernetes-the-hard-way, chapters 04, 05 and 06.

k8s_tls_certs:
  entities:
    ca:
      key: |
        <Insert your ca key here!>
      cert: |
        <Insert your ca cert here!>
    admin:
      key: |
        <Insert your admin key here!>
      cert: |
        <Insert your admin cert here!>
    kube_controller:
      key: |
        <Insert your controller-manager key here!>
      cert: |
        <Insert your controller-manager cert here!>
    kube_scheduler:
      key: |
        <Insert your scheduler key here!>
      cert: |
        <Insert your scheduler cert here!>
    kubernetes:
      key: |
        <Insert your kubernetes key here!>
      cert: |
        <Insert your kubernetes cert here!>
    service-accounts:
      key: |
        <Insert your service-accounts key here!>
      cert: |
        <Insert your service-accounts cert here!>

k8s_control_plane:
  
  # Root directory for configs ad kubeconfigs
  rootdirs:
    - '/etc/k8s'
    - '/etc/k8s/conf'
    - '/etc/k8s/kubeconfig'
    - '/etc/k8s/yamlconf'

  # /* Root dir for data files like keys, certs etc if not embedded. */
  vardir: '/var/lib/k8s'

  kubectl:
    pkg_name: 'kubernetes-kubectl'
    pkg_version: '1.18.14-1.el7'

    # /* Path to kubectl kubeconfig */
    path_to_admin_kubeconfig: '/etc/k8s/kubeconfig/admin.kubeconfig'
    
    # /* Path to the directory where manifests to apply are placed */
    yamldir: '/etc/k8s/yamlconf'

    # /* Host where manifests from yamldir can be applied with kubectl to cluster. */
    management_host: 'k8s-cp1.asgardahost.ru'

  apiserver:
    pkg_name: 'kubernetes-kube-apiserver'
    pkg_version: '1.18.14-1.el7'
    enable: true

    # /* Apiserver unit file parameters. */
    parameters:
      binarypath: '/opt/k8s/kube-apiserver'
      common:
        allow-privileged: true
        apiserver-count: 3
        audit-log-maxage: 30
        audit-log-maxbackup: 3
        audit-log-maxsize: 100
        audit-log-path: '/var/log/audit.log'
        authorization-mode: 'Node,RBAC'
        bind-address: '0.0.0.0'
        client-ca-file: '/var/lib/k8s/own_ca.crt'
        enable-admission-plugins: 'NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota'
        etcd-cafile: '/var/lib/k8s/own_ca.crt'
        etcd-certfile: '/var/lib/k8s/k8s-api.crt'
        etcd-keyfile: '/var/lib/k8s/k8s-api.key'
        etcd-servers: 'https://192.168.100.8:2379,https://192.168.100.9:2379,https://192.168.100.10:2379'
        event-ttl: '1h'
        encryption-provider-config: '/var/lib/k8s/encryption-config.yaml'
        kubelet-certificate-authority: '/var/lib/k8s/own_ca.crt'
        kubelet-client-certificate: '/var/lib/k8s/k8s-api.crt'
        kubelet-client-key: '/var/lib/k8s/k8s-api.key'
        kubelet-https: 'true'
        runtime-config: 'api/all=true'
        service-account-key-file: '/var/lib/k8s/service-accounts.crt'
        service-cluster-ip-range: '10.32.0.0/24'
        service-node-port-range: '30000-32767'
        tls-cert-file: '/var/lib/k8s/k8s-api.crt'
        tls-private-key-file: '/var/lib/k8s/k8s-api.key'
        v: 2

      # /* Obligatory hash where all apiservers in the folowing format must be enumerated. */
      apiservers_advertise:
        k8s-cp1:
          ip_address: "192.168.100.8"
        k8s-cp2:
          ip_address: "192.168.100.9"
        k8s-cp3:
          ip_address: "192.168.100.10"

  scheduler:
    pkg_name: 'kubernetes-kube-scheduler'
    pkg_version: '1.18.14-1.el7'
    enable: true

    # /* Parameters for scheduler unit file. */
    parameters:
      binarypath: '/opt/k8s/kube-scheduler'
      common:
        config: '/etc/k8s/conf/kube-scheduler.yaml'
        v: 2

      # /* Scheduler config */
      conf:
        '/etc/k8s/conf/kube-scheduler.yaml':
          apiVersion: kubescheduler.config.k8s.io/v1alpha1
          kind: KubeSchedulerConfiguration
          clientConnection:
            kubeconfig: "/etc/k8s/kubeconfig/kube-scheduler.kubeconfig"
          leaderElection:
            leaderElect: true

  control-manager:
    pkg_name: 'kubernetes-kube-controller-manager'
    pkg_version: '1.18.14-1.el7'
    enable: true

    # /* Parameters for control-manager unit file. */
    parameters:
      binarypath: '/opt/k8s/kube-controller-manager'
      common:
        address: '0.0.0.0'
        cluster-cidr: '10.200.0.0/16'
        cluster-name: 'k8s-asgardahost'
        cluster-signing-cert-file: '/var/lib/k8s/own_ca.crt'
        cluster-signing-key-file: '/var/lib/k8s/own_ca.key'
        kubeconfig: '/etc/k8s/kubeconfig/kube-controller-manager.kubeconfig'
        leader-elect: true
        root-ca-file: '/var/lib/k8s/own_ca.crt'
        service-account-private-key-file: '/var/lib/k8s/service-accounts.key'
        service-cluster-ip-range: '10.32.0.0/24'
        use-service-account-credentials: true
        v: 2

# /* Configs for data encryption */
k8s_encryption-config:
  kind: EncryptionConfig
  apiVersion: v1
  resources:
    - resources:
        - secrets
      providers:
        - aescbc:
            keys:
              - name: key1
	        secret: <Secret for data encryption is here!>
        - identity: {}

# /* Control plane kubeconfigs */
k8s_kubeconfigs:
  admin:
    < Insert your admin kubeconfig here! >
  '/etc/k8s/kubeconfig/kube-controller-manager.kubeconfig':
    < Insert your contoller-manager kubeconfig here! >
  '/etc/k8s/kubeconfig/kube-scheduler.kubeconfig':
    < Insert your scheduler kubeconfig here! >
```


It will install apiserver, kube-scheduler and control-manager pckages, put keys, certs, confiigs and kubeconfigs  under specified directories and generate a systemd unit files for launching all components of the contro plane. Here is a list of generated files:
```bash
/etc/k8s
/etc/k8s/conf
/etc/k8s/conf/kube-scheduler.yaml
/etc/k8s/kubeconfig
/etc/k8s/kubeconfig/kube-scheduler.kubeconfig
/etc/k8s/kubeconfig/kube-controller-manager.kubeconfig
/etc/k8s/yamlconf
/etc/systemd/system/k8s-api.service
/etc/systemd/system/k8s-controller-manager.service
/etc/systemd/system/k8s-scheduler.service
/var/lib/k8s
/var/lib/k8s/k8s-api.key
/var/lib/k8s/own_ca.crt
/var/lib/k8s/service-accounts.key
/var/lib/k8s/own_ca.key
/var/lib/k8s/k8s-api.crt
/var/lib/k8s/encryption-config.yaml
/var/lib/k8s/service-accounts.crt
```

