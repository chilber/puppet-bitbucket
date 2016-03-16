# == Class bitbucket::config
#
# This class is called from bitbucket for configuration.
#
class bitbucket::config {

  # server.xml
  file { "${::bitbucket::webappdir}/conf/server.xml":
    ensure  => 'present',
    content => template('bitbucket/server.xml.erb'),
    owner   => $::bitbucket::user,
    group   => $::bitbucket::group,
    mode    => '0640',
  }

  # setenv.sh settings
  file_line {'bitbucket_java_home':
    ensure => present,
    path   => "${::bitbucket::webappdir}/bin/setenv.sh",
    line   => "  export JAVA_HOME=${::bitbucket::javahome}",
    match  => 'export JAVA_HOME=',
  }

  file_line {'bitbucket_home':
    ensure => present,
    path   => "${::bitbucket::webappdir}/bin/setenv.sh",
    line   => "  export BITBUCKET_HOME=${::bitbucket::homedir}",
    match  => 'export BITBUCKET_HOME=',
  }

  file_line {'bitbucket_umask':
    ensure => present,
    path   => "${::bitbucket::webappdir}/bin/setenv.sh",
    line   => 'umask 0027',
    match  => '^# umask 0027$',
  }

  ini_setting { 'bitbucket_jvm_minimum_memory':
    ensure  => present,
    path    => "${::bitbucket::webappdir}/bin/setenv.sh",
    section => '',
    setting => 'JVM_MINIMUM_MEMORY',
    value   => $::bitbucket::jvm_minimum_memory,
  }

  ini_setting { 'bitbucket_jvm_maximum_memory':
    ensure  => present,
    path    => "${::bitbucket::webappdir}/bin/setenv.sh",
    section => '',
    setting => 'JVM_MAXIMUM_MEMORY',
    value   => $::bitbucket::jvm_maximum_memory,
  }

  # user.sh settings
  ini_setting { 'bitbucket_user':
    ensure  => present,
    path    => "${::bitbucket::webappdir}/bin/user.sh",
    section => '',
    setting => 'BITBUCKET_USER',
    value   => $::bitbucket::user,
  }

  ini_setting { 'bitbucket_shell':
    ensure  => present,
    path    => "${::bitbucket::webappdir}/bin/user.sh",
    section => '',
    setting => 'SHELL',
    value   => '/bin/bash',
  }

  # scripts.cfg
  ini_setting { 'bitbucket_httpport':
    ensure            => present,
    path              => "${::bitbucket::webappdir}/conf/scripts.cfg",
    section           => '',
    key_val_separator => '=',
    setting           => 'bitbucket_httpport',
    value             => $::bitbucket::tomcat_port,
  }

  # Only do the setup on first installation
  $defaults = {
    'path' => "${::bitbucket::homedir}/shared/bitbucket.properties",
    'key_val_separator' => '=',
  }
  create_ini_settings({ '' => $::bitbucket::config_properties }, $defaults)

}
