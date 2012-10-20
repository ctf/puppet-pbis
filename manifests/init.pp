class likewise (
  $domain,
  $bindUsername,
  $bindPassword        = hiera('bindPassword'),
  $ou                  = ''
  $userDomainPrefix    = '',
  $assumeDefaultDomain = true,
  ) {

  # Likewise Open is not packaged for Red Hat, Fedora, or CentOS
  if $osfamily != 'Debian' {
    fail('This module is currently only supported on Debian and derivatives.')
  }
  
  package { 'likewise-open':
    ensure => latest,
  }

  service { 'lsassd':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package['likewise-open'],
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
    command => "domainjoin-cli join ${options} ${domain} ${bindUsername} ${bindPassword}",
    require => Service['lsassd'],
  }
}
