class likewise (
  $ADdomain,
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
  
  $options = ''
  
  if $ou {
    $likewiseOU = getOU($ou)
    $options += '--ou ${likewiseOU} '
  }
  if $userDomainPrefix {
    $options += '--userDomainPrefix ${userDomainPrefix} '
  }
  if $assumeDefaultDomain == true {
    $options += '--assumeDefaultDomain yes '
  }
  else {
    $options += '--assumeDefaultDomain no '
  }
  
  exec { 'join_domain':
    path    => ['/usr/bin'],
    command => "domainjoin-cli join ${options} ${ADdomain} ${bindUsername} ${bindPassword}",
    require => Service['lsassd'],
  }
}
