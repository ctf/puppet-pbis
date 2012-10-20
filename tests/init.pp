class { 'likewise':
  ADdomain         => 'ads.example.org',
  bindUsername     => 'admin',
  bindPassword     => 'password',
  ou               => 'ou=Computers,ou=Department,ou=Divison',
  userDomainPrefix => 'ADS',
}
