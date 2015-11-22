# Class: bitbucket
# ===========================
class bitbucket (
  # JVM Settings
  $javahome = '/opt/java',
  $jvm_minimum_memory = '512m',
  $jvm_maximum_memory = '1024m',
  $jvm_support_recommended_args = '',

  # Stash Settings
  $version = '4.0.2',
  $checksum = '25bc382ea55de3d5fd5427edd54535ab',
  $product = 'bitbucket',
  $format = 'tar.gz',
  $installdir = '/opt/bitbucket',
  $homedir = '/home/bitbucket',
  $context_path = '',
  $tomcat_port = 7990,

  # User and Group Management Settings
  $manage_usr_grp = true,
  $user = 'bitbucket',
  $group = 'bitbucket',
  $uid = undef,
  $gid = undef,

  $setup_properties = {
    'setup.displayName' => 'Bitbucket server',
    'setup.baseUrl' => "https://${::fqdn}",
    'setup.license' => 'AAABLw0ODAoPeNptkE1rwkAQhu/7KxZ6aQ8ryfoRERaqSSjSxJRoSw+9rMtYF/MhsxNb++sbG4uleBgY5uN5552bVQM8M8RlwP1g0pcTr8/DaMWl5w9ZBM6g3ZOtKzWztG7MDojfLgEPgHdvEx4fdNHoU5+FCD9JpAnUaVv4npBjFtYVaUNxqm2hSkC0RPc71Lv6w9IXYM/UJbtwFGEDzJF22167Zg/QVQproHLwAuhOU5K1vIqg0pWB+HNv8fhH2BdyxDJ815V1HTXthPnjRfgsknTg1XEPC12CCrM0jfNwPk1Y53MeqVkQPYggy6cimqavYpwPQ7aMF6oNkYwCzx8MJDuD2vFkHl3rXD+zu2JJGglQbXThfu0vmnINmG2eXWtaCZ89NWi22sH/F38D+heU9jAsAhRzwj0ZMcWaXhhdIX+OCg7nkclBOgIUZquqAoEy4BoxUU5FVWYAUektn8Y=X02f7',
    'setup.sysadmin.username' => 'admin',
    'setup.sysadmin.password' => 'password',
    'setup.sysadmin.displayName' => 'John Doe',
    'setup.sysadmin.emailAddress' => 'root@localhost',
  },
  $config_properties = {
    'dbuser' => 'bitbucket',
    'dbpassword' => 'password',
    'dburl' => 'jdbc:hsqldb:${bitbucket.home}/data/db;shutdown=true',
    'dbdriver' => 'org.hsqldb.jdbcDriver',
  },

  # Database Settings
  # Misc Settings
  $download_url = 'http://www.atlassian.com/software/bitbucket/downloads/binary/',
  $deploy_module = 'archive',

  # Manage service
  $service_manage = true,
  $service_ensure = running,
  $service_enable = true,

  # Command to stop bitbucket in preparation to upgrade.
  $stop_bitbucket = 'service bitbucket stop && sleep 15',

  # Once of task to migrate from stash to bitbucket
  $migrate_from_stash = false,
  $migrate_homedir = '/home/stash',
  $migrate_installdir = '/opt/stash',
  $migrate_user = 'stash',

) inherits ::bitbucket::params {

  $webappdir = "${installdir}/atlassian-${product}-${version}"
  $file = "atlassian-${product}-${version}.${format}"

  anchor { 'bitbucket::start': } ->
  class { '::bitbucket::install': } ->
  class { '::bitbucket::config': } ~>
  class { '::bitbucket::service': } ->
  anchor { 'bitbucket::end': }

}
