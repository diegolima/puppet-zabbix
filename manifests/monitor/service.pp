class zabbix::monitor::service () {
  if(! defined(Class['zabbix::monitor'])){
    class{'zabbix::monitor':}
  }
  if(! defined(Class['zabbix::monitor::host'])){
    class{'zabbix::monitor::host':}
  }
  Class['zabbix::monitor'] -> Class['zabbix::monitor::host'] -> Class['zabbix::monitor::service']
}

#
# Service Template
# Parameters:
#       $s_template = Name of the Zabbix Template that will be associated to the service
#       $s_hostname = Host that will have the service configured on it
#
define zabbix::service(
  $s_template,
  $s_hostname = $::hostname,
) {
  $s_t_template = inline_template("<% require 'cgi' %><%= CGI.escape(\"$s_template\") %>")
  $s_t_hostname = inline_template("<% require 'cgi' %><%= CGI.escape(\"$s_hostname\") %>")

  # Exact URL that will be used during API calls. DO NOT CHANGE UNLESS YOU KNOW WHAT YOU'RE DOING
  $s_apitalk  = "$::zabbix::monitor::params::api_service?name=$title&template_name=$s_t_template&hostname=$s_t_hostname"

  Exec { path => ['/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'] }
  exec{"apitalk::$title":
    command => "curl -f -o /dev/null -s \'$s_apitalk\'",
    unless  => "test -f /tmp/apitalk::service::$title",
    notify  => Exec["apitalk::lock::$title"],
  }
  exec{"apitalk::lock::$title":
    command     => "touch /tmp/apitalk::service::$title",
    refreshonly => true,
  }


  # Uncomment to debug API calls
  notify {"apitalk::$title - curl -f -o /dev/null -s $s_apitalk": }

  # Make sure we're only changing a service after the host
  Class['zabbix::monitor'] -> Class['zabbix::monitor::host'] -> Class['zabbix::monitor::service'] -> Exec["apitalk::$title"] -> Exec["apitalk::lock::$title"] -> Notify["apitalk::$title - curl -f -o /dev/null -s $s_apitalk"]
}

