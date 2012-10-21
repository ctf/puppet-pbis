class likewise (
  $adDomain,
  $bindUsername,
  $bindPassword,
  $ou = undef,
  $userDomainPrefix = undef,
  $assumeDefaultDomain = true,
  ) {

  # Likewise Open is not packaged for Red Hat, Fedora, or CentOS
  if $osfamily != 'Debian' {
    fail('Module ${modulename} is not supported on ${operatingsystem}.')
  }
  
  package { 'likewise-open':
    ensure => latest,
  }

  service { 'lsassd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['likewise-open'],
  }
  
  # Construct the domainjoin-cli options string
  if $ou {
    $likewiseOU = getOU($ou)
    $optionOU = "--ou ${likewiseOU}"
  }
  else {
    $optionOU = ''
  }
  if $userDomainPrefix {
    $optionPrefix = "--userDomainPrefix ${userDomainPrefix}"
  }
  else {
    $optionPrefix = ''
  }
  if $assumeDefaultDomain == true {
    $optionAssume = "--assumeDefaultDomain yes"
  }
  else {
    $optionAssume = "--assumeDefaultDomain no"
  }
  
  $options = "${optionOU} ${optionPrefix} ${optionAssume}"
  
  # Join the machine if it is not already on the domain.
  if $adDomain != $domain {
    exec { 'join_domain':
      path    => ['/usr/bin'],
      command => "domainjoin-cli join ${options} ${adDomain} ${bindUsername} ${bindPassword}",
      require => Service['lsassd'],
    }
    # Update DNS
    exec { 'update_DNS':
      path    => ['/usr/bin'],
      command => "lw-update-dns",
      require => Exec['join_domain'],
    }
  }
}
