class pbis (
  $adDomain,
  $bindUsername,
  $bindPassword,
  $ou = undef,
  $userDomainPrefix = undef,
  $assumeDefaultDomain = true,
  $disable = undef
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
  if $disable {
    $optionDisable = "--disable ${disable}"
  }
  else {
    $optionDisable = ""
  }
    
  $options = "${optionOU} ${optionPrefix} ${optionAssume} ${optionDisable}"
    
  # Join the machine if it is not already on the domain.
  exec { 'join_domain':
    path    => ['/usr/bin', '/bin'],
    command => "domainjoin-cli join ${options} ${adDomain} ${bindUsername} ${bindPassword}",
    require => Service['lwsmd'],
    unless => "/opt/pbis/bin/lsa ad-get-machine account 2> /dev/null | grep 'NetBIOS Domain Name'",
  }

  # Update DNS
  exec { 'update_DNS':
    path    => ['/opt/pbis/bin'],
    command => "/opt/pbis/bin/update-dns",
    require => Exec['join_domain'],
    returns => [0, 204],
  }
}
