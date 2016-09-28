class pbis (
  $ad_domain,
  $bind_username,
  $bind_password,
  $ou                    = $pbis::params::ou,
  $enabled_modules       = $pbis::params::enabled_modules,
  $disabled_modules      = $pbis::params::disabled_modules,
  $package               = $pbis::params::package,
  $package_file          = $pbis::params::package_file,
  $package_file_provider = $pbis::params::package_file_provider,
  $upgrade_package       = $pbis::params::upgrade_package,
  $upgrade_package_file  = $pbis::params::upgrade_package_file,
  $service_name          = $pbis::params::service_name,
  $assume_default_domain = $pbis::params::assume_default_domain,
  $create_home_dir       = $pbis::params::create_home_dir,
  $home_dir_prefix       = $pbis::params::home_dir_prefix,
  $home_dir_umask        = $pbis::params::home_dir_umask,
  $home_dir_template     = $pbis::params::home_dir_template,
  $login_shell_template  = $pbis::params::login_shell_template,
  $require_membership_of = $pbis::params::require_membership_of,
  $skeleton_dirs         = $pbis::params::skeleton_dirs,
  $user_domain_prefix    = $pbis::params::user_domain_prefix,
  $repository            = $pbis::params::repository,
  $dns_ipaddress         = $pbis::params::dns_ipaddress,
  $dns_ipv6address       = $pbis::params::dns_ipv6address,

  ) inherits pbis::params {

  wget::fetch { "${repository}/${package_file}":
    destination => "/tmp/${package_file}",
    timeout     => 0,
    verbose     => false,
  } ->
    # Install the packages.
  exec { 'install pbis':
    command => "/bin/sh /tmp/${package_file} install",
    unless  => "rpm -qa | grep pbis-open-${pbis::params::version}.${::architecture} -ci",
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => Exec['install pbis'],
  }
  # Construct the domainjoin-cli options string
  # AssumeDefaultDomain and UserDomainPrefix are configured after joining
  if $ou {
    $opt_ou = "--ou \"${ou}\""
  }
  else {
    $opt_ou = ''
  }
  if $enabled_modules {
    $opt_enabled_modules = "--enable ${enabled_modules}"
  }
  else {
    $opt_enabled_modules = ''
  }
  if $disabled_modules {
    $opt_disabled_modules = "--disable ${disabled_modules}"
  }
  else {
    $opt_disabled_modules = ''
  }

  $options = "${opt_ou} ${opt_enabled_modules} ${opt_disabled_modules}"

  # Join the machine if it is not already on the domain.
  exec { 'join_domain':
    command => "/opt/pbis/bin/domainjoin-cli join ${options} ${ad_domain} ${bind_username} ${bind_password}",
    require => Service[$service_name],
    unless  => '/opt/pbis/bin/lsa ad-get-machine account 2> /dev/null | grep "NetBIOS Domain Name"',
  }

  # Update DNS

  if ( $dns_ipaddress ) {
    $dns_ipaddress_args = "--ipaddress ${dns_ipaddress}"
  }
  else {
    $dns_ipaddress_args = ''
  }

  exec { 'update_DNS':
    command     => "/opt/pbis/bin/update-dns ${dns_ipaddress_args}",
    require     => Exec['join_domain'],
    returns     => [0, 204],
    refreshonly => true,
  }

  # Configure PBIS

  $pbis_conf = '/etc/pbis/pbis.conf'

  file { $pbis_conf:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('pbis/pbis.conf.erb'),
    require => Exec['join_domain'],
    notify  => Exec['clear_ad_cache'],
  }

  exec { 'configure_pbis':
    command     => "/opt/pbis/bin/config --file ${pbis_conf}",
    subscribe   => File[$pbis_conf],
    refreshonly => true,
  }

  exec { 'clear_ad_cache':
    path        => ['/opt/pbis/bin'],
    command     => '/opt/pbis/bin/ad-cache --delete-all',
    subscribe   => Exec['configure_pbis'],
    refreshonly => true,
  }
}
