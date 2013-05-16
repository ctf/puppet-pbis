class pbis::params {

  $ou                    = undef
  $user_domain_prefix    = undef
  $assume_default_domain = true
  $enabled_modules       = undef
  $disabled_modules      = undef

  $pbis_release = '7.1.0'
  $pbis_revision = '1203'

  if !( $::architecture in ['amd64', 'x86_64', 'i386'] ) {
    fail("Unsupported architecture: ${::architecture}.")
  }

  # PBIS Open is packaged for Red Hat, Suse, and Debian derivatives.
  # Choose the .deb or .rpm automatically.
  $package = $::osfamily ? {
    'Debian'          => "pbis-open_${pbis_release}.${pbis_revision}_${::architecture}.deb",
    '/(RedHat|Suse)/' => "pbis-open-${pbis_release}-${pbis_revision}.${::architecture}.rpm",
    default           => "Unsupported operating system: ${::operatingsystem}.",
  }
}
