# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
include sudo
include zabbix

class { 'zabbix::agent':
  server => ['10.0.0.80','127.0.0.1'],
}
class { 'zabbix::monitor::host': 
  h_group    => 'phpuppet',
  h_mapname  => 'phpuppet',
  h_maplayer => '20',
}
class { 'zabbix::monitor::service': }

zabbix::service { 'Linux':
  s_template => 'so_linux',
}
zabbix::service { 'Apache2':
  s_template => 'httpd_server',
}
zabbix::service { 'SSHd':
  s_template => 'ssh_server',
}
