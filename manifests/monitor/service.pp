class zabbix::monitor::service (
  $name,
  $template,
  $hostname = $::hostname,
) {
  if(! defined(Class['zabbix::monitor'])){
    class{'zabbix::monitor': }
  }
  zabbix::service { "$name":
    name     => "$name",
    template => "$template",
    hostname => "$hostname",
  }
}

define zabbix::service(
  $name,
  $template,
  $hostname,
) {
  Exec { path => ['/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'] }
  exec{'apitalk':
    command => "curl -o -s $::zabbix::monitor::params::api_service?name=$name&template=$template&hostname=$hostname"
  }
  notify {"apitalk - curl -o -s $::zabbix::monitor::params::api_service?name=$name&template=$template&hostname=$hostname": }
}
