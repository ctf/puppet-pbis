# puppet-likewise

Joins a node to an Active Directory domain using Likewise Open.

## Usage

    node 'workstation' {
      class { 'likewise': 
        ADdomain         => 'ads.example.org',
        bindUsername     => 'admin',
        bindPassword     => 'password',
        ou               => 'ou=Computers,ou=Department,ou=Divison',
        userDomainPrefix => 'ADS',
      }
    }

## Environment

This module is being developed against:

  * Puppet 2.7.19
  * Facter 1.6.13

## Supported platforms

For now, only the Debian family is supported. Other operating systems which provide a Likewise Open package will be added.
