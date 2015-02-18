class pbis::params {

  # package options
  $use_repository        = false
  $package               = 'pbis-open'
  $service_name          = 'lsass'

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

  case $::osfamily {
     'Debian':        { $package_file = "${package}.${::architecture}.deb" }
     'RedHat','Suse': { $package_file = "${package}.${::architecture}.rpm" }
     default:         {
       fail("Unsupported operating system: ${::operatingsystem}.")
     }
  }

  case $::osfamily {
    'Debian':        { $package_file_provider = 'dpkg' }
    'RedHat','Suse': { $package_file_provider = 'rpm' }
    default:         {
      fail("Unsupported operating system: ${::operatingsystem}.")
    }
  }

}
