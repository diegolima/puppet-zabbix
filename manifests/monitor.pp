class zabbix::monitor (
  $label        = $::hostname,
  $hostname     = $::hostname,
  $monitored    = true,
) {

  # Class requirements and Ordering
  if(! defined(Class['zabbix']))
  {
    class{ 'zabbix': }
    Class['zabbix'] -> Class['zabbix::monitor']
  }
  if(defined(Class['zabbix::agent']))
  {
    Class['zabbix::agent'] -> Class['zabbix::monitor']
  }

  # declare all parameterized classes
  class { 'zabbix::monitor::params': }

  package{ "$::zabbix::monitor::params::pkg_curl":
        ensure => 'present',
  }
}
