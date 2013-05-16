class { 'pbis':
  ad_domain             => 'ads.example.org',
  bind_username         => 'admin',
  bind_password         => 'password',
  ou                    => 'ou=Computers,ou=Department,ou=Divison',
  user_domain_prefix    => 'ADS',
}
