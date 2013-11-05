class zabbix::monitor::params {
  $pkg_curl = $::osfamily ? {
    'Debian' => 'curl',
    'RedHat' => 'curl',
  }
  $api_host    = 'http://localhost/host.php'
  $api_service = 'http://localhost/service.php'

}
