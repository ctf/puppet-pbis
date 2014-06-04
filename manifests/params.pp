class pbis::params {

  # package options
  $use_repository        = false
  $package               = 'pbis-open'
  $service_name          = 'lsass'
  
  # parameter ignored when using repository, but needed when using builtin
  # fileserver after pbis v7.1.1 (see bug #3)
  # set this to empty string to disable the preinstallation
  $package_prerequired   = 'pbis-open-upgrade'

  # domainjoin-cli options
  $ou                    = undef
  $enabled_modules       = undef
  $disabled_modules      = undef

  # PBIS configuration
  $assume_default_domain = true
  $create_home_dir       = true
  $domain_separator      = '\\'
  $space_replacement     = '_'
  $home_dir_prefix       = '/home'
  $home_dir_umask        = '022'
  $home_dir_template     = '%H/%D/%U'
  $login_shell_template  = '/bin/bash'
  $require_membership_of = undef
  $skeleton_dirs         = '/etc/skel'
  $user_domain_prefix    = undef

  if !( $::architecture in ['amd64', 'x86_64', 'i386'] ) {
    fail("Unsupported architecture: ${::architecture}.")
  }

  # PBIS Open is packaged for Red Hat, Suse, and Debian derivatives.
  # When using Puppet's built-in fileserver, choose the .deb or .rpm 
  # automatically.
  $package_file_suffix = $::osfamily ? {
    'Debian'          => "${::architecture}.deb",
    /(RedHat|Suse)/   => "${::architecture}.rpm",
    default           => fail("Unsupported operating system: ${::operatingsystem}."),
  }
  $package_file_provider = $::osfamily ? {
    'Debian'          => 'dpkg',
    /(RedHat|Suse)/   => 'rpm',
    default           => fail("Unsupported operating system: ${::operatingsystem}."),
  }
}
