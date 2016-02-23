# == Class bitbucket::install
#
# This class is called from bitbucket for install.
#
class bitbucket::install {

  if $::bitbucket::manage_usr_grp {
    group { $::bitbucket::group:
      ensure => present,
      gid    => $::bitbucket::gid,
    }

    user { $::bitbucket::user:
      ensure           => present,
      comment          => 'Bitbucket daemon account',
      shell            => '/bin/bash',
      home             => $::bitbucket::homedir,
      password         => '*',
      password_min_age => '0',
      password_max_age => '99999',
      managehome       => true,
      uid              => $::bitbucket::uid,
      gid              => $::bitbucket::gid,
      before           => [ File[$::bitbucket::installdir], File[$bitbucket::homedir] ],
    }
  }

  file { [ $::bitbucket::installdir, $bitbucket::homedir ]:
    ensure => 'directory',
    owner  => $::bitbucket::user,
    group  => $::bitbucket::group,
  }

  case $::bitbucket::deploy_module {
    'staging': {
      require ::staging
      staging::file { $bitbucket::file:
        source  => "${::bitbucket::download_url}/${::bitbucket::file}",
        timeout => 1800,
      } ->
      staging::extract { $::bitbucket::file:
        target  => $::bitbucket::installdir,
        creates => $::bitbucket::webappdir,
        user    => $::bitbucket::user,
        group   => $::bitbucket::group,
        notify  => Exec["chown_${::bitbucket::webappdir}"],
        require => [
          File[$::bitbucket::installdir],
          User[$::bitbucket::user],
        ],
      }
    }
    'archive': {
      require ::archive
      archive { "/tmp/${::bitbucket::file}":
        ensure        => present,
        extract       => true,
        extract_path  => $::bitbucket::installdir,
        source        => "${::bitbucket::download_url}/${::bitbucket::file}",
        creates       => $::bitbucket::webappdir,
        cleanup       => true,
        checksum_type => 'md5',
        checksum      => $::bitbucket::checksum,
        user          => $::bitbucket::user,
        group         => $::bitbucket::group,
        notify        => Exec["chown_${::bitbucket::webappdir}"],
        require       => [
          File[$::bitbucket::installdir],
          User[$::bitbucket::user],
        ],
      }
    }
    default: {
      fail('deploy_module parameter must equal "archive" or "staging"')
    }
  }

  file { "${::bitbucket::homedir}/shared":
    ensure => 'directory',
    owner  => $::bitbucket::user,
    group  => $::bitbucket::group,
    mode   => '0700',
  }

  # Only do the setup on first installation
  # work around until we get some movement on PUP-1125
  $bitbucket_properties = "${::bitbucket::homedir}/shared/bitbucket.properties"
  file { '/var/tmp/.bitbucket.yaml':
    ensure  => 'file',
    content => template('bitbucket/bitbucket.yaml.erb'),
    owner   => $::bitbucket::user,
    group   => $::bitbucket::group,
    mode    => '0700',
  }

  file { $bitbucket_properties:
    ensure => 'file',
    owner  => $::bitbucket::user,
    group  => $::bitbucket::group,
    mode   => '0640',
  }

  unless str2bool($::bitbucket_setup) {
    $defaults = {
      'path' => $bitbucket_properties,
      'key_val_separator' => '=',
      'require' => File[$bitbucket_properties],
    }
    create_ini_settings({ '' => $::bitbucket::setup_properties }, $defaults)
  }

  exec { "chown_${::bitbucket::webappdir}":
    command     => "/bin/chown -R ${::bitbucket::user}:${::bitbucket::group} ${bitbucket::webappdir}",
    refreshonly => true,
  }

  # Add LSB if needed, per: https://confluence.atlassian.com/bitbucketserver/running-bitbucket-server-as-a-linux-service-776640157.html#RunningBitbucketServerasaLinuxservice-Runningonsystemboot
  if $::bitbucket::lsb_package {
    package { $::bitbucket::lsb_package:
      ensure => installed,
    }
  }
}
