class zabbix::monitor::params {
  $pkg_curl = $::osfamily ? {
    'Debian' => 'curl',
    'RedHat' => 'curl',
  }
  $api_host    = 'http://10.100.0.90/puppetTOzabbix/main.php'
  $api_service = 'http://10.100.0.90/puppetTOzabbix/service.php'
}
