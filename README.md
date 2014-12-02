# puppet-pbis

Joins a node to an Active Directory domain using PowerBroker Identity Services Open Edition (PBIS).

## Usage

    node 'workstation' {
      class { 'pbis': 
        ad_domain             => 'ads.example.org',
        bind_username         => 'admin',
        bind_password         => 'password',
        ou                    => 'ou=Computers,ou=Department,ou=Divison',
        user_domain_prefix    => 'ADS',
        require_membership_of => 'ADS\\Linux_Users',
      }
    }

## Distributing PBIS Open packages

This module supports two ways of distributing the PBIS Open packages:

1. using Puppet's built-in fileserver, and
2. as `package` resources using an external repository.

The default is to use Puppet's built-in fileserver.

In either case, download the necessary packages from the [BeyondTrust website](http://www.beyondtrust.com/Technical-Support/Downloads/PowerBroker-Identity-Services-Open-Edition/?Pass=True). Extract the architecture-specific `pbis-open` `.rpm` or `.deb` file from the self-extracting `sh` archive.

### Using Puppet's built-in fileserver

Rename the `pbis-open` package files according to the following convention:

    pbis-open.amd64.deb
    pbis-open.i386.deb

    pbis-open.x86_64.rpm
    pbis-open.i386.rpm
    
and place them in the module's `files/` folder.

### Using an external repository

For scalability, or if you are using variable module paths, you may want to add the PBIS Open packages to a local `apt` or `yum` repository.

In that case, include the class with `use_repository => true`.

    node 'workstation' {
      class { 'pbis':
        ...
        use_repository => true,
      }
    }

### Service name change.

The service name may not be 'lsass' on newer version of PBIS and may be 'lwsmd'. This is now configurable as below:

    node 'workstation' {
      class { 'pbis':
        ...
        service_name => 'lwsmd',
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
