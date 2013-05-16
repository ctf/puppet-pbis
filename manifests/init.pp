class pbis (
  $ad_domain,
  $bind_username,
  $bind_password,
  $ou                    = $pbis::params::ou,
  $user_domain_prefix    = $pbis::params::user_domain_prefix,
  $assume_default_domain = $pbis::params::assume_default_domain,
  $enabled_modules       = $pbis::params::enabled_modules,
  $disabled_modules      = $pbis::params::disabled_modules,
  $package               = $pbis::params::package,
  ) inherits pbis::params {

  # Download and install the package from the puppetmaster...
  # a low-performance repo for the poor man
  file { "/opt/${package}":
    ensure  => file,
    source  => "puppet:///modules/pbis/files/${package}",
  }

  package { 'pbis-open':
    ensure  => installed,
    source  => "/opt/${package}",
    require => File["/opt/${package}"],
  }

  service { 'lwsmd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['pbis-open'],
  }

  # Construct the domainjoin-cli options string
  if $ou {
    $pbisOU = getOU($ou)
    $optionOU = "--ou ${pbisOU}"
  }
  else {
    $optionOU = ''
  }
  if $user_domain_prefix {
    $optionPrefix = "--userDomainPrefix ${user_domain_prefix}"
  }
  else {
    $optionPrefix = ''
  }
  if $assume_default_domain == true {
    $optionAssume = '--assumeDefaultDomain yes'
  }
  else {
    $optionAssume = '--assumeDefaultDomain no'
  }
  if $disabled_modules {
    $optionDisable = "--disable ${disabled_modules}"
  }
  else {
    $optionDisable = ''
  }

  $options = "${optionOU} ${optionPrefix} ${optionAssume} ${optionDisable}"

  # Join the machine if it is not already on the domain.
  exec { 'join_domain':
    path    => ['/usr/bin', '/bin'],
    command => "domainjoin-cli join ${options} ${ad_domain} ${bind_username} ${bind_password}",
    require => Service['lwsmd'],
    unless  => '/opt/pbis/bin/lsa ad-get-machine account 2> /dev/null | grep "NetBIOS Domain Name"',
  }

  # Update DNS
  exec { 'update_DNS':
    path    => ['/opt/pbis/bin'],
    command => '/opt/pbis/bin/update-dns',
    require => Exec['join_domain'],
    returns => [0, 204],
  }

  # Configure PBIS
  file { '/etc/pbis/configSettings':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('pbis/configSettings.erb'),
    require => Exec['join_domain'],
    notify  => Exec[clearCache],
  }

  exec { 'pbisConfig':
    path        => ['/opt/pbis/bin'],
    command     => '/opt/pbis/bin/config --file /etc/pbis/configSettings',
    subscribe   => File['/etc/pbis/configSettings'],
    refreshonly => true,
  }

  exec { 'clearCache':
    path        => ['/opt/pbis/bin'],
    command     => '/opt/pbis/bin/ad-cache --delete-all',
    subscribe   => Exec['pbisConfig'],
    refreshonly => true,
  }

}
