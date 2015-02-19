class pbis::params {

  # package options
  $use_repository        = false
  $package               = 'pbis-open'
  $upgrade_package       = 'pbis-open-upgrade'
  $service_name          = 'lsass'

  # domainjoin-cli options
  $ou                    = undef
  $enabled_modules       = undef
  $disabled_modules      = undef

  # PBIS configuration
  $assume_default_domain = false
  $create_home_dir       = true
  $domain_separator      = '\\'
  $space_replacement     = '^'
  $home_dir_prefix       = '/home'
  $home_dir_umask        = '022'
  $home_dir_template     = '%H/local/%D/%U'
  $login_shell_template  = '/bin/sh'
  $require_membership_of = undef
  $skeleton_dirs         = '/etc/skel'
  $user_domain_prefix    = undef

  if !( $::architecture in ['amd64', 'x86_64', 'i386'] ) {
    fail("Unsupported architecture: ${::architecture}.")
  }

  # PBIS Open is packaged for Red Hat, Suse, and Debian derivatives.
  # When using Puppet's built-in fileserver, choose the .deb or .rpm 
  # automatically.

  # Get the packaging Format and Set the package installation provider
  case $::osfamily {
   'Debian':        { 
      $package_file_provider = 'dpkg' 
      $package_format = "deb" 
    }
    'RedHat','Suse': { 
      $package_file_provider = 'rpm' 
      $package_format = "rpm" 
    }
    default:         {
      fail("Unsupported operating system: ${::operatingsystem}.")
    }
  }

  # Build the file names.
  $package_file =
    "${package}.${::architecture}.${package_format}"
  $upgrade_package_file =
    "${upgrade_package}.${::architecture}.${package_format}"
}
