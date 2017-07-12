# puppet-pbis

Joins a node to an Active Directory domain using PowerBroker Identity Services Open Edition (PBIS).

## Usage

    node 'workstation' {
      class { 'pbis': 
        ad_domain             => 'ads.example.org',
        bind_username         => 'admin',
        bind_password         => 'password',
        ou                    => 'division/Department/computers',
        user_domain_prefix    => 'ADS',
        require_membership_of => 'ADS\\Linux_Users',
        version               => "8.5.3-293"
      }
    }

## Distributing PBIS Open packages

This module supports two ways of distributing the PBIS Open packages:

1. using Puppet's built-in fileserver, and
2. as `package` resources using an external repository.

The default is to use Puppet's built-in fileserver.

In either case, download the necessary packages from the [BeyondTrust Repo website](https://repo.pbis.beyondtrust.com/).
You can access the x86_64 RPMs directly, for example: (https://repo.pbis.beyondtrust.com/yum/pbiso/x86_64/Packages/)

### Using Puppet's built-in fileserver

Rename the `pbis-open` package files according to the following convention:

    pbis-open.amd64.deb
    pbis-open.i386.deb

    pbis-open.x86_64.rpm
    pbis-open.i386.rpm
    
and place them in the module's `files/` folder.

### Using an external repository

For scalability, or if you are using variable module paths, you may want to add the PBIS Open packages to a local `apt` or `yum` repository.

In that case, sync with the [BeyondTrust Public Repo](https://repo.pbis.beyondtrust.com), and set $yum_install => true (the default)

### Service name change.

The service name was changed from 'lsass' to 'lwsmd' in Likewise Open 6.0, and therefore all versions of PBIS. This is now configurable as below:

    node 'workstation' {
      class { 'pbis':
        ...
        service_name => 'lwsmd',
      }
    }

## Dependencies

This module requires the `osfamily` fact, which depends on Facter 1.6.1+.
This module requires the 'wget' module, which you can get via: `puppet module install maestrodev-wget --version 1.7.3`

## Supported platforms

This module has been tested against Puppet 2.7.18+ and Facter 1.6.9+ on Debian 7 and Ubuntu 12.04.

Support for RedHat and Suse is included and has been tested 2016-11-16.

## Contributing

Please open a pull request with any changes or bugfixes.

## History

Likewise Open was acquired by BeyondTrust in 2011 and rebranded as PowerBroker Identity Services Open Edition. The project page is at [powerbrokeropen.org](http://www.powerbrokeropen.org).

The original Likewise Open package is included in the Ubuntu repositories, but has not been updated in years.
