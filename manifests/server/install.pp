class zabbix::server::install (
  $zabbix_db,
  $zabbix_user,
  $zabbix_password,
) {
  Exec{ path => '/usr/bin' }

  mysql::db{ 'zabbix':
    user    => 'zabbix',
    password => $zabbix_password,
    require => Class['::mysql::server'],
  }

  if ! defined(File['/root/preseed/'])
  {
    file { '/root/preseed':
      ensure => directory,
      mode   => '0750',
    }
  }

  file { '/root/preseed/zabbix-server.preseed':
    content => template('zabbix/server.preseed.erb'),
    mode    => '0600',
    backup  => false,
    require => File['/root/preseed'],
  }

  package { $zabbix::server::params::package_name:
    ensure       => installed,
    responsefile => '/root/preseed/zabbix-server.preseed',
    require      => [Mysql::Db['zabbix'], File['/root/preseed/zabbix-server.preseed'] ],
    notify       => Exec['importSchema'],
  }

  exec { 'importSchema':
    command     => "mysql -u $zabbix_user --password=$zabbix_password $zabbix_db < /usr/share/zabbix-server-mysql/schema.sql ",
    notify      => Exec['importImages'],
    refreshonly => true,
  }
  exec { 'importImages':
    command => "mysql -u $zabbix_user --password=$zabbix_password $zabbix_db < /usr/share/zabbix-server-mysql/images.sql ",
    refreshonly => true,
    notify      => Exec['importData'],
  }
  exec { 'importData':
    command => "mysql -u $zabbix_user --password=$zabbix_password $zabbix_db < /usr/share/zabbix-server-mysql/data.sql ",
    refreshonly => true,
  }

  Package[$zabbix::server::params::package_name] -> Exec['importSchema'] -> Exec['importImages'] -> Exec['importData']
}
