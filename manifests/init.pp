# Class: bitbucket
# ===========================
#
# This module is used to install Bitbucket.
#
# See README.md for more details.
#
class bitbucket (
  # JVM Settings
  $javahome                     = '/opt/java',
  $jvm_minimum_memory           = '512m',
  $jvm_maximum_memory           = '1024m',
  $jvm_support_recommended_args = '',

  # Bitbucket Settings
  $version      = '4.3.2',
  $checksum     = '5e1d2393a840ae2f11ceeb8d78c1ba5d',
  $product      = 'bitbucket',
  $format       = 'tar.gz',
  $installdir   = '/opt/bitbucket',
  $homedir      = '/home/bitbucket',
  $context_path = '',
  $tomcat_port  = 7990,

  # User and Group Management Settings
  $manage_usr_grp = true,
  $user           = 'bitbucket',
  $group          = 'bitbucket',
  $uid            = undef,
  $gid            = undef,

  # Bitbucket initialization settings
  $display_name      = 'Bitbucket',
  $base_url          = "https://${::fqdn}",
  $license           = '',
  $sysadmin_username = 'admin',
  $sysadmin_password = 'bitbucket',
  $sysadmin_name     = 'Bitbucket Admin',
  $sysadmin_email    = 'root@localhost',
  $config_properties = {},

  # Database Settings
  $dbuser     = 'bitbucket',
  $dbpassword = 'password',
  $dburl      = 'jdbc:postgresql://localhost:5432/bitbucket',
  $dbdriver   = 'org.postgresql.Driver',

  # Misc Settings
  $download_url = 'http://www.atlassian.com/software/stash/downloads/binary',
  $deploy_module = 'archive',

  # Manage service
  $service_manage = true,
  $service_ensure = running,
  $service_enable = true,

  # Reverse https proxy
  $proxy = {},

  # Command to stop bitbucket in preparation to upgrade.
  $stop_bitbucket = 'service bitbucket stop && sleep 15',

  # One-off task to migrate from stash to bitbucket
  $migrate_from_stash = false,
  $migrate_homedir    = '/home/stash',
  $migrate_installdir = '/opt/stash',
  $migrate_user       = 'stash',
  $migrate_group      = 'stash',
  $migrate_stop       = 'service stash stop && sleep 15',
) inherits ::bitbucket::params {

  validate_absolute_path($javahome)
  validate_string($jvm_minimum_memory)
  validate_string($jvm_maximum_memory)
  validate_string($jvm_support_recommended_args)

  validate_string($version)
  if $checksum {
    validate_string($checksum)
  }
  validate_string($product)
  validate_string($format)
  validate_absolute_path($installdir)
  validate_absolute_path($homedir)
  validate_string($context_path)
  validate_integer($tomcat_port)

  validate_bool($manage_usr_grp)
  validate_string($user)
  validate_string($group)

  validate_string($display_name)
  validate_string($base_url)
  validate_string($license)
  validate_string($sysadmin_username)
  validate_string($sysadmin_password)
  validate_string($sysadmin_name)
  validate_string($sysadmin_email)
  validate_hash($config_properties)

  validate_string($dbuser)
  validate_string($dbpassword)
  validate_string($dburl)
  validate_string($dbdriver)

  validate_string($download_url)
  validate_re($deploy_module, [ '^archive', '^staging' ])

  validate_bool($service_manage)
  validate_re($service_ensure, [ '^running', '^stopped' ])
  validate_bool($service_enable)

  validate_hash($proxy)

  validate_string($stop_bitbucket)

  validate_bool($migrate_from_stash)
  validate_absolute_path($migrate_homedir)
  validate_absolute_path($migrate_installdir)
  validate_string($migrate_user)
  validate_string($migrate_group)
  validate_string($migrate_stop)

  $webappdir = "${installdir}/atlassian-${product}-${version}"
  $file = "atlassian-${product}-${version}.${format}"
  $setup_properties = {
    'setup.displayName' => $display_name,
    'setup.baseUrl' => $base_url,
    'setup.license' => $license,
    'setup.sysadmin.username' => $sysadmin_username,
    'setup.sysadmin.password' => $sysadmin_password,
    'setup.sysadmin.displayName' => $sysadmin_name,
    'setup.sysadmin.emailAddress' => $sysadmin_email,
    'jdbc.driver' => $dbdriver,
    'jdbc.url' => $dburl,
    'jdbc.user' => $dbuser,
    'jdbc.password' => $dbpassword,
  }

  if defined('$::bitbucket_version') {
    if versioncmp($version, $::bitbucket_version) > 0 {
      # If the running version of bitbucket is less than the expected version
      # Shut it down in preparation for upgrade.
      notify { "Attempting to upgrade bitbucket from ${::bitbucket_version} to ${version}": }
      exec { $stop_bitbucket:
        path   => '/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/bin',
        before => Class['::bitbucket::install'],
      }
    }
  }

  if $migrate_from_stash {
    notify { 'Attempting to upgrade from Stash': }
    class { '::bitbucket::migrate':
      before => Class['::bitbucket::install'],
    }
  }

  anchor { 'bitbucket::start': } ->
  class { '::bitbucket::install': } ->
  class { '::bitbucket::config': } ~>
  class { '::bitbucket::service': } ->
  anchor { 'bitbucket::end': }
}
