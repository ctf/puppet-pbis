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
  $sync_system_time      = $pbis::params::sync_system_time,
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

  notice("Starting PBIS class configuration.")
  if $yum_install {
    wget::fetch { $pbis::params::repo_source:
      destination => $pbis::params::repo_dest,
      timeout     => 0,
      verbose     => false,
      unless      => "grep -ci 'enabled=1' ${pbis::params::repo_dest}",
    } ->
    exec { 'refresh package list':
      command => $pbis::params::repo_refresh,
      path => ['/usr/bin', '/usr/sbin', '/bin'],
      unless => "${pbis::params::repo_search} | grep '${pbis::params::version}.${pbis::params::version_qfe}' -ci",
      logoutput => 'on_failure',
    } ->
    # SELinux relabel can take a long time, give the install literally 10 minutes to complete
    exec { 'install pbis':
      command => "${pbis::params::repo_install} ${package}",
      path => ['/usr/bin', '/usr/sbin', '/bin'],
      unless => "grep -ci '${pbis::params::version}.${pbis::params::version_build}' ${version_file}",
      logoutput => 'on_failure',
      timeout => 600,
    }
  }
  else {
    wget::fetch { "${repository}/${package_file}":
      destination => "/tmp/${package_file}",
      timeout     => 0,
      verbose     => false,
    } ->
    # Install the packages.
    # SELinux relabel can take a long time, give the install literally 10 minutes to complete
    exec { 'install pbis':
      command => "/bin/sh /tmp/${package_file} install",
      path    => ['/usr/bin', '/usr/sbin', '/bin'],
      unless => "${pbis::params::repo_search} | grep '${pbis::params::version}.${pbis::params::version_qfe}' -ci",
      logoutput => 'on_failure',
      timeout => 600
    }
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => Exec['install pbis'],  #requiring this instead of the existence of the package allows controlling the version via puppet, rather than via "yum upgrade".
    #require -> Package[$package],    # comment out the previous line, and uncomment this line, to simply base the requirement on "being installed" rather than a specific version
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
  if $sync_system_time {
    $opt_sync_system_time = ''
  }
  else {
    $opt_sync_system_time = "--notimesync"
  }

  $options = "${opt_ou} ${opt_enabled_modules} ${opt_disabled_modules} ${opt_sync_system_time}"

  # Join the machine if it is not already on the domain.
  exec { 'join_domain':
    command => "/opt/pbis/bin/domainjoin-cli join ${options} ${ad_domain} ${bind_username} ${bind_password}",
    logoutput => true,
    require => Service[$service_name],
    unless  => '/opt/pbis/bin/lsa ad-get-machine account 2> /dev/null',
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
  #  notify  => Exec['clear_ad_cache'],
  # not needed, since the config command does that for us if required (based on the options in the file)
  }

  exec { 'configure_pbis':
    command     => "/opt/pbis/bin/config --file ${pbis_conf}",
    subscribe   => File[$pbis_conf],
    refreshonly => true,
  }

# This isn't required, since "/opt/pbis/bin/config" will refresh/clear cache as required for the settings set.
# It is therefore actually potentially dangerous, as some versions of PBIS will clear the cache even if the host is offline.
#  exec { 'clear_ad_cache':
#    path        => ['/opt/pbis/bin'],
#    command     => '/opt/pbis/bin/ad-cache --delete-all',
#    subscribe   => Exec['configure_pbis'],
#    refreshonly => true,
#  }
}
