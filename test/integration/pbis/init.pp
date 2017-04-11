class { 'pbis':
  ad_domain          => 'child1.lwtest.corp',
  bind_username      => 'root-access',
  bind_password      => 'RobHome1',
  ou                 => 'Company/Branch/Computers',
  user_domain_prefix => 'CHILD2',
  repository         => 'http://repo.pbis.beyondtrust.com',
}
