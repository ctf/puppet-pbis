class pbis (
  $adDomain,
  $bindUsername,
  $bindPassword,
  $ou = undef,
  $userDomainPrefix = undef,
  $assumeDefaultDomain = true,
  ) {

  # PowerBroker Identity Services – Open Edition is not packaged for Red Hat, Fedora, or CentOS
  if $osfamily != 'Debian' {
    fail('Module ${modulename} is not supported on ${operatingsystem}.')
  }
  
  package { 'pbis-open':
    ensure => latest,
  }

  service { 'lwsmd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['pbis-open'],
  }
  
  # Join the machine if it is not already on the domain.
  if $adDomain != $domain {
    # Construct the domainjoin-cli options string
    if $ou {
      $pbisOU = getOU($ou)
      $optionOU = "--ou ${pbisOU}"
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
    
    exec { 'join_domain':
      path    => ['/usr/bin'],
      command => "domainjoin-cli join ${options} ${adDomain} ${bindUsername} ${bindPassword}",
      require => Service['lwsmd'],
    }
    
    # Update DNS
    exec { 'update_DNS':
      path    => ['/opt/pbis/bin'],
      command => "update-dns",
      require => Exec['join_domain'],
    }
  }
}
