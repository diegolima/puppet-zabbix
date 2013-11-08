#
# Parameters: Mapping through parameters <-> Zabbix Host Definitions
#
#       $h_group     = In groups; MUST be in at least in 1 group.
#       $h_name      = Host name; Defaults to current hostname
#       $h_vname     = Visible name; Defaults to current fqdn. Currently unused
#       $h_hostname  = DNS Name; Defaults to fqdn
#       $h_ipaddress = IP Address; Defaults to first IP address (usually eth0)
#       $h_useip     = Whether to use the IP address instead of the DNS to monitor the host. Defaults to "0" (use DNS). Possible values: "0" (use DNS) or "1" (use IP)
#       $h_port      = Agent port; Defaults to '10050'
#       $h_hosttype  = Interfaces; currently unused and reserved for SNMP/JMX/IPMI monitoring
#       $h_proxy     = Monitored by Proxy; Defaults to none. Currently unused and reserved for DM support
#       $h_status    = Status; Defaults to "0" (Monitored). Possible values: "0" (monitored) or "1" (not monitored)
#       $h_mapname   = Name of the map the host will belong to. Defaults to none.
#       $h_maplayer  = Used to calculate the position of the host on the map. Defaults to 10.
#
class zabbix::monitor::host (
        $h_group,
        $h_name      = $::hostname,
        $h_vname     = $::hostname,
        $h_hostname  = $::fqdn,
        $h_ipaddress = $::ipaddress,
        $h_useip     = '0',
        $h_port      = '10050',
        $h_hosttype  = 'agent',
        $h_proxy     = false,
        $h_status    = '0',
        $h_mapname   = false,
        $h_maplayer  = '10',
) {
  if(! defined(Class['zabbix::monitor'])){
    class{'zabbix::monitor':}
  }
  Exec { path => ['/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'] }

  # Sanitize input
  $h_t_mapname   = inline_template("<% require 'cgi' %><%= CGI.escape(\"$h_mapname\") %>")
  $h_t_group     = inline_template("<% require 'cgi' %><%= CGI.escape(\"$h_group\") %>")
  $h_t_name      = inline_template("<% require 'cgi' %><%= CGI.escape(\"$h_name\") %>")
  $h_t_hostname  = inline_template("<% require 'cgi' %><%= CGI.escape(\"$h_hostname\") %>")
  $h_t_ipaddress = inline_template("<% require 'cgi' %><%= CGI.escape(\"$h_ipaddress\") %>")

  # Exact URL that will be used during API calls. DO NOT CHANGE UNLESS YOU KNOW WHAT YOU'RE DOING
  $h_apitalk   = "$::zabbix::monitor::params::api_host?hostname=$h_t_name&hostgroup=$h_t_group&dns=$h_t_hostname&ip=$h_t_ipaddress&use_ip=$h_useip&port=$h_port&status=$h_status&map_name=$h_t_mapname&layer=$h_maplayer"

  exec{"apitalk::$::hostname":
    command => "curl -f -o /dev/null -s \'$h_apitalk\'",
    unless  => "test -f /tmp/apitalk::host::$::hostname",
    notify  => [ Exec["apitalk::lock::$::hostname"], Notify["apitalk::$hostname - curl -f -o /dev/null -s $h_apitalk"] ],
  }

  exec{"apitalk::lock::$::hostname":
    command     => "touch /tmp/apitalk::host::$::hostname",
    refreshonly => true,
  }

  notify {"apitalk::$::hostname - curl -f -o /dev/null -s $h_apitalk": }

  # Resource Ordering
  Exec["apitalk::$::hostname"] -> Exec["apitalk::lock::$::hostname"] -> Notify["apitalk::$hostname - curl -f -o /dev/null -s $h_apitalk"]
  Class['zabbix::monitor'] -> Class['zabbix::monitor::host']
}
