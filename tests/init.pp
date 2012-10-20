class { 'likewise':
  adDomain         => 'ads.example.org',
  bindUsername     => 'admin',
  bindPassword     => 'password',
  ou               => 'ou=Computers,ou=Department,ou=Divison',
  userDomainPrefix => 'ADS',
}
