class zabbix::params {
  $zabbix_version = '2.0'

  # Deal with "derivated" distros
  $repo_distro    = $::lsbdistid ? {
    'elementary OS' => 'ubuntu',
    default         => inline_template("<%= @lsbdistid.downcase %>")
  }
  $repo_release   = $::lsbdistcodename ? {
    'luna'  => 'precise',
    default => inline_template("<%= @lsbdistcodename.downcase %>")
  }

  $repo_arch      = $::architecture ? {
    /(amd64|x86_64)/ => 'x86_64',
    'i386'           => 'i386',
  }

  # Repository URLs
  $repo_location  = $::operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => "http://repo.zabbix.com/zabbix/$zabbix_version/$repo_distro",
    /(?i-mx:centos|fedora|redhat)/ => "http://repo.zabbix.com/zabbix/$zabbix_version/rhel/$::operatingsystemmajrelease/\$basearch/",
  }
}