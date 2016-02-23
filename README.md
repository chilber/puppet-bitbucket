# Bitbucket Puppet Module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with bitbucket](#setup)
    * [What bitbucket affects](#what-bitbucket-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with bitbucket](#beginning-with-bitbucket)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview
This is a puppet module to install [Atlassian Bitbucket Server](https://www.atlassian.com/software/bitbucket) — on-premises source code management for Git that's secure, fast, and enterprise grade.

## Module Description
This module installs/upgrades Atlassian's Enterprise source code management tool. The bitbucket module also manages the Bitbucket Server configuration files with Puppet.

## Setup

### What bitbucket affects

If installing to an existing Bitbucket instance, it is your responsibility to backup your database. We also recommend that you backup your Bitbucket home directory and that you align your current Bitbucket version with the version you intend to use with the puppet Bitbucket module.

You must have your database setup with the account user that Bitbucket will use. This can be done using the [puppetlabs-postgresql](https://forge.puppetlabs.com/puppetlabs/postgresql) and [puppetlabs-mysql](https://forge.puppetlabs.com/puppetlabs/mysql) modules. The mysql java connector can be installed using the [puppet/mysql_java_connector](https://forge.puppetlabs.com/puppet/mysql_java_connector) module.

On RedHat/CentOS 6 systems, this module will also ensure that `redhat-lsb` is installed, [per Atlassian's recommendations](https://confluence.atlassian.com/bitbucketserver/running-bitbucket-server-as-a-linux-service-776640157.html#RunningBitbucketServerasaLinuxservice-Runningonsystemboot).

### Setup Requirements

* Bitbucket requires a Java Developers Kit (JDK) or Java Run-time Environment (JRE) platform to be installed on your server's operating system. Oracle JDK / JRE (formerly Sun JDK / JRE) versions 1.8 and Open JDK/ JRE versions 1.8u0 - 1.8u20 and 1.8u40+ are [currently supported by Atlassian](https://confluence.atlassian.com/bitbucketserver/supported-platforms-776640981.html#Supportedplatforms-javaSupportedplatformsdetailsJava).
* Bitbucket requires a relational database to store its configuration data. This module currently supports PostgreSQL 8.4 to 9.x and MySQL 5.x. We suggest using the [puppetlabs-postgresql](https://forge.puppetlabs.com/puppetlabs/postgresql) or [puppetlabs-mysql](https://forge.puppetlabs.com/puppetlabs/mysql) modules to configure/manage the database. The module uses PostgreSQL as a default.
* Bitbucket requires Git 1.8.0+ (excluding 1.8.4.3, 2.0.2, and 2.0.3). RedHat/CentOS 6 and Debian 7 systems ship with Git 1.7 by default. You will need to upgrade Git in order to run Bitbucket, but this module does not provide that functionality at present.
* While not required, for production use we recommend using nginx/apache as a reverse proxy to Bitbucket. We suggest using the [jfryman-nginx](https://forge.puppetlabs.com/jfryman/nginx) puppet module.

### Beginning with bitbucket

This puppet module will automatically download the Bitbucket tar.gz from Atlassian and extracts it into `/opt/bitbucket/atlassian-bitbucket-$version`. The default Bitbucket home is `/home/bitbucket`.

```puppet
  class { 'bitbucket': }
```

```puppet
  class { 'bitbucket':
    version        => '4.0.2',
    javahome       => '/etc/alternatives/java',
    dburl          => 'jdbc:postgresql://bitbucket.example.com:5433/bitbucket',
    dbpassword     => $bitbucketpass,
  }
```

Enable external facts for bitbucket version.
```puppet
  class { 'bitbucket::facts': }
```

#### Upgrades

##### Upgrades to Bitbucket

Bitbucket can be upgraded by incrementing the `version` number. This will *STOP* the running instance of Bitbucket and attempt to upgrade. You should take caution when doing large version upgrades. Always backup your database and your home directory. The `bitbucket::facts` class is required for upgrades.

```puppet
  class { 'bitbucket':
    version  => '4.3.2',
  }
  class { 'bitbucket::facts': }
```

If the bitbucket service is managed outside of puppet the `stop_bitbucket` paramater can be used to shut down Bitbucket.
```puppet
  class { 'bitbucket':
    version    => '4.3.2',
    stop_bitbucket => 'crm resource stop bitbucket && sleep 15',
  }
  class { 'bitbucket::facts': }
```

##### Migrating from Stash

Bitbucket can be migrated from Stash with the `migrate_from_stash` parameter. This will *STOP* the running instance of Stash and attempt to migrate the user, group, and home directory. You should take caution when migrating. Always backup your database and your home directory.

```puppet
  class { 'bitbucket':
    migrate_from_stash  => true,
  }
```

If the stash service is managed outside of puppet the `migrate_stop` paramater can be used to shut down Stash prior to migrating.

```puppet
  class { 'bitbucket':
    migrate_from_stash  => true,
    migrate_stop => 'crm resource stop stash && sleep 15',
  }
```

## Usage

This module also allows for direct customization of the JVM, following [Atlassian's recommendations](https://confluence.atlassian.com/display/JIRA/Setting+Properties+and+Options+on+Startup).

This is especially useful for setting properties such as HTTP/https proxy settings. Support has also been added for reverse proxying stash via Apache or nginx.

### A more complex example

```puppet
  class { 'bitbucket':
    version        => '4.3.2',
    installdir     => '/opt/atlassian/atlassian-bitbucket',
    homedir        => '/opt/atlassian/application-data/bitbucket-home',
    javahome       => '/etc/alternatives/java',
    download_url    => 'http://example.com/pub/software/development-tools/atlassian/',
    dburl          => 'jdbc:postgresql://dbvip.example.com:5433/bitbucket',
    dbpassword     => $bitbucketpass,
    service_manage => false,
    jvm_xms        => '1G',
    jvm_xmx        => '4G',
    java_opts      => '-Dhttp.proxyHost=proxy.example.com -Dhttp.proxyPort=8080 -Dhttps.proxyHost=proxy.example.com -Dhttps.proxyPort=8080 -Dhttp.nonProxyHosts=\"localhost|127.0.0.1|172.*.*.*|10.*.*.*|*.example.com\"',
    proxy          => {
      scheme       => 'https',
      proxyName    => 'bitbucket.example.com',
      proxyPort    => '443',
    },
    tomcat_port    => '7991'
  }
  class { 'bitbucket::facts': }
```

### A Hiera example

The dbpassword can be stored using eyaml hiera extension.

```yaml
# Bitbucket configuration
bitbucket::version:        '4.3.2'
bitbucket::installdir:     '/opt/atlassian/atlassian-bitbucket'
bitbucket::homedir:        '/opt/atlassian/application-data/bitbucket-home'
bitbucket::javahome:       '/opt/java'
bitbucket::dburl:          'jdbc:postgresql://dbvip.example.com:5433/bitbucket'
bitbucket::service_manage: false
bitbucket::download_url:    'http://example.com/pub/software/development-tools/atlassian'
bitbucket::jvm_xms:        '1G'
bitbucket::jvm_xmx:        '4G'
bitbucket::java_opts: >
  -XX:+UseLargePages
  -Dhttp.proxyHost=proxy.example.com
  -Dhttp.proxyPort=8080
  -Dhttps.proxyHost=proxy.example.com
  -Dhttps.proxyPort=8080
  -Dhttp.nonProxyHosts=localhost\|127.0.0.1\|172.*.*.*\|10.*.*.*\|*.example.com
bitbucket::env:
  - 'http_proxy=proxy.example.com:8080'
  - 'https_proxy=proxy.example.com:8080'
bitbucket::proxy:
  scheme:     'https'
  proxyName:  'bitbucket.example.com'
  proxyPort:  '443'
bitbucket::bitbucket_stop: '/usr/sbin crm resource stop bitbucket'
```

## Reference

### Classes

#### Public classes
* `bitbucket`: Main class, manages the installation and configuration of Bitbucket.
* `bitbucket::facts`: Enable external facts for running instance of Bitbucket. This class is required to handle upgrades of Bitbucket. As it is an external fact, we chose not to enable it by default.

#### Private classes
* `bitbucket::install`: Installs Bitbucket binaries
* `bitbucket::config`: Modifies Bitbucket/Tomcat configuration files
* `bitbucket::service`: Manage the Bitbucket service
* `bitbucket::migrate`: Migrate Stash user, group, and home directory to Bitbucket

### Parameters

#### Bitbucket parameters

##### `javahome`
Specify the java home directory. Default: `/opt/java`
##### `version`
Specifies the version of Bitbucket to install, defaults to latest available at time of module upload to the forge. It is **recommended** to pin the version number to avoid unnecessary upgrades of Bitbucket.
##### `format`
The format of the file Bitbucket will be installed from. Default: `'tar.gz'`
##### `installdir`
The installation directory of the bitbucket binaries. Default: `'/opt/bitbucket'`
##### `homedir`
The home directory of Bitbucket. Configuration files are stored here. Default: `'/home/bitbucket'`
##### `manage_usr_grp`
Whether or not this module will manage the bitbucket user and group associated with the install.
You must either allow the module to manage both aspects or handle both outside the module. Default: `true`
##### `user`
The user that bitbucket should run as, as well as the ownership of bitbucket related files. Default: `'bitbucket'`
##### `group`
The group that bitbucket files should be owned by. Default: `'bitbucket'`
##### `uid`
Specify a uid of the bitbucket user. Default: `undef`
##### `gid`
Specify a gid of the bitbucket user: Default: `undef`

#### Database parameters
##### `dbuser`
The name of the database user that stash should use. Default: `'bitbucket'`
##### `dbpassword`
The database password for the database user. Default: `'password'`
##### `dburl`
The uri to the bitbucket database server. Default: `'jdbc:postgresql://localhost:5432/bitbucket'`
##### `dbdriver`
The driver to use to connect to the database. Default: `'org.postgresql.Driver'`

#### JVM Java parameters
##### `jvm_xms`
Default: `'512m'`
##### `jvm_xmx`
Default: `'1024m'`
##### `jvm_support_recommended_args`
Default: `''`

#### Tomcat parameters
##### `context_path`
Specify context path, defaults to `''`.
If modified, Once Bitbucket has started, go to the administration area and click Server Settings (under 'Settings'). Append the new context path to your base URL.
##### `tomcat_port`
Specify the port that you wish to run tomcat under, defaults to `7990`
##### `proxy`
Reverse https proxy configuration. See examples for more detail. Default: `{}`

#### Miscellaneous parameters
##### `download_url`
Where to download the stash binaries from. Default: 'http://www.atlassian.com/software/stash/downloads/binary/'
##### `checksum`
The md5 checksum of the archive file. Only supported with `deploy_module => archive`. Defaults to `'undef'`
##### `service_manage`
Should puppet manage this service? Default: `true`
##### `$service_ensure`
Manage the bitbucket service, defaults to `'running'`
##### `$service_enable`
Defaults to `'true'`
##### `$stop_stash`
If the bitbucket service is managed outside of puppet the stop_bitbucket paramater can be used to shut down bitbucket for upgrades. Defaults to `'service bitbucket stop && sleep 15'`
##### `deploy_module`
Module to use for installed bitbucket archive fille. Supports puppet-archive and puppet-staging. Defaults to `'archive'`. Archive supports md5 hash checking, Staging support s3 buckets.
##### `config_properties`
Extra configuration options for bitbucket (bitbucket.properties). See [the Bitbucket documentation](https://confluence.atlassian.com/bitbucketserver/bitbucket-server-config-properties-776640155.html) for available options. Must be a hash, Default: `{}`

#### Migration parameters
##### `migrate_from_stash`
Should puppet migrate bitbucket from a stash instance?
Default: `false`
##### `migrate_homedir`
Home directory of the Stash instance to migrate.
Default: `'/home/stash'`
##### `migrate_installdir`
Install directory of the Stash instance to migrate.
Default: `'/opt/stash'`
##### `migrate_user`
User of the Stash instance to migrate.
Default: `'stash'`
##### `migrate_group`
Group of the Stash instance to migrate.
Default: `'stash'`
##### `migrate_stop`
Command to stop Stash prior to migrating.
Default: `'service stash stop && sleep 15'`

## Limitations

* Puppet 3.4+
* Puppet Enterprise

The puppetlabs repositories can be found at: http://yum.puppetlabs.com/ and http://apt.puppetlabs.com/

* RedHat / CentOS 6 / 7
* Ubuntu 14.04
* Debian 7 / 8

## Development

Please feel free to raise any issues here for bug fixes. We also welcome feature requests. Feel free to make a pull request for anything and we make the effort to review and merge. We prefer with tests if possible.
