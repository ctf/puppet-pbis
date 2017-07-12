class { 'pbis':
  ad_domain          => 'child1.bttest.corp',
  bind_username      => 'joinusers',
  bind_password      => 'Password1',
  ou                 => 'Company/Branch/Computers',
  user_domain_prefix => 'CHILD1',
  repository         => 'https://repo.pbis.beyondtrust.com',
}
