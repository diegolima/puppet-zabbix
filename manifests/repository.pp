class zabbix::repository (
    $repo_location = $zabbix::params::repo_location,
    $repo_release  = $zabbix::params::repo_release,
  ) inherits zabbix::params {

  case $::operatingsystem {
    'debian', 'ubuntu': {
      include apt
      apt::source { 'zabbix':
        include_src => true,
        location    => "$repo_location",
        repos       => 'main',
        release     => "$repo_release",
        key         => '79EA5ED4',
        key_source  => 'http://repo.zabbix.com/zabbix-official-repo.key',
      }
    }
    'centos', 'fedora', 'redhat': {
      yumrepo { 'zabbix':
        baseurl  => "$repo_location",
        gpgcheck => 0,
      }
    }
  }
}
