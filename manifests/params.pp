class pbis::params {

  # package options
  $repository            = 'http://repo.pbis.beyondtrust.com'
  $product_name          = 'pbis'
  $product_class         = 'open'
  $package               = "${product_name}-${product_class}"
  $upgrade_package       = "${package}-upgrade"
  $legacy_package        = "${package}-legacy"
  $gui_package           = "${package}-gui"
  $version               = '8.5'
  $version_qfe           = '3'
  $version_build         = '293'
  $package_version       = "${version}.${version_qfe}-${version_build}"
  $service_name          = 'lwsmd'
  # expect 'yum' or 'wget' below.  'wget' performs the 2016-11-15 and earlier install of wget + rpm -Uvh
  # true  = yum, which pulls from the public PBIS repo (or your own sync to Spacewalk)
  $yum_install = true

  # domainjoin-cli options
  $ou                    = undef
  $enabled_modules       = undef
  $disabled_modules      = undef

  # PBIS configuration
  $assume_default_domain = false
  $create_home_dir       = true
  $home_dir_prefix       = '/home'
  $home_dir_umask        = '022'
  $home_dir_template     = '%H/%D/%U'
  $login_shell_template  = '/bin/sh'
  $require_membership_of = undef
  $skeleton_dirs         = '/etc/skel'
  $user_domain_prefix    = undef

  # Added by EV 3/16/2016
  # Adding PBIS parameter "SyncSystemTime" - can be either true or false (default)
  # Set to 'false' to allow NTPD daemon sync the machine's time
  $sync_system_time  = false

  # update-dns options
  #$dns_ipaddress         = undef
  $dns_ipaddress         = $ipaddress_ens32  # forces using ens32 address, so that multi-homed hosts don't register all addresses
  $dns_ipv6address       = undef

  if !( $::architecture in ['amd64', 'x86_64', 'i386', 'ppc64', 'ppc64le',] ) {
    fail("Unsupported architecture- ${::architecture}.")
  }

  case $product_class {
    'open': {
        $repo_class = 'pbiso'
    }
    'enterprise': {
        $repo_class = 'pbise'
    }
    default:  {
        $repo_class = 'pbiso'
    }
  }

  # PBIS Open is packaged for Red Hat, Suse, and Debian derivatives.
  # When using Puppet's built-in fileserver, choose the .deb or .rpm 
  # automatically.

  # Get the packaging Format and Set the package installation provider
  case $::osfamily {
    'Debian':        {
      $package_file_provider = 'dpkg'
      $package_format = 'deb'
      $repo_base = 'apt'
      $repo_ext = 'list'
      case $repo_class {
        'pbiso': {
          $package_source = "${repository}/${repo_base}/pool/main/p/${package}/${package}-${package_version}.${::archtecture}.rpm"
        }
        'pbise': {
          $package_source = "${repository}/${repo_base}/pool/non-free/p/${package}/${package}-${package_version}.${::archtecture}.rpm"
        }
      }
      $repo_dest = "/etc/apt/sources.list.d/${repo_class}.${repo_ext}"
      $repo_refresh = "apt update"
      $repo_install = "apt -y install"
      $repo_search = "apt-cache show ${package}"
    }
    'RedHat','Suse': {
      $package_file_provider = 'rpm'
      $package_format = 'rpm'
      $repo_base = 'yum'
      $repo_ext = 'repo'
      $package_source = "${repository}/${repo_base}/${repo_class}/${::architecture}/Packages/${package}-${package_version}.${::architecture}.rpm"
      $repo_dest = "/etc/yum.repos.d/${repo_class}.${repo_ext}"
      $repo_refresh = "yum clean all"
      $repo_install = "yum -y install"
      $repo_search = "yum list available ${package} --showduplicates"
    }
    default:         {
      fail("Unsupported operating system: ${::operatingsystem}.")
    }
  }

  # Build the file names.
  $package_file =
    "${package}-${package_version}.linux.${::architecture}.${package_format}.sh"
  $upgrade_package_file =
    "${upgrade_package}-${package_version}.linux.${::architecture}.${package_format}.sh"
  $repo_source = "${repository}/${repo_base}/${repo_class}.${repo_ext}"
}
