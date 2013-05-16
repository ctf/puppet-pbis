# puppet-pbis

Joins a node to an Active Directory domain using PowerBroker Identity Services Open Edition (PBIS).

## Usage

1. Download PBIS from the [BeyondTrust website](www.beyondtrust.com/Technical-Support/Downloads/PowerBroker-Identity-Services-Open-Edition/?Pass=True).
2. Extract the `.rpm` or `.deb` file from the self-extracting `sh` archive.
3. Rename the files according to the following convention:

        pbis-open.amd64.deb
        pbis-open.i386.deb
    
        pbis-open.x86_64.rpm
        pbis-open.i386.rpm
    
  and place them in the module's `files/` folder.
4. Apply the class to a node. See `manifests/init.pp` for more options.

        node 'workstation' {
          class { 'pbis': 
            ad_domain          => 'ads.example.org',
            bind_username      => 'admin',
            bind_password      => 'password',
            ou                 => 'ou=Computers,ou=Department,ou=Divison',
            user_domain_prefix => 'ADS',
          }
        }

## Dependencies

This module requires the `osfamily` fact, which depends on Facter 1.6.1+.

## Supported platforms

This module has been tested against Puppet 2.7.18+ and Facter 1.6.9+ on Debian 7 and Ubuntu 12.04.

Support for RedHat and Suse is included but has not been tested.

## Contributing

Please open a pull request with any changes or bugfixes.

## History

Likewise Open was acquired by BeyondTrust in 2011 and rebranded as PowerBroker Identity Services Open Edition. The project page is at [powerbrokeropen.org](http://www.powerbrokeropen.org).

The original Likewise Open package is included in the Ubuntu repositories, but has not been updated in years.
