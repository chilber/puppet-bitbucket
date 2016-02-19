# == Class bitbucket::service
#
# This class is called from bitbucket for service management.
#
class bitbucket::service {

  file { $::bitbucket::service_file_location:
    content => template($::bitbucket::service_file_template),
    mode    => '0755',
  }

  if $::bitbucket::service_manage {

    if $::bitbucket::service_file_location =~ /systemd/ {
      exec { 'refresh_systemd':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File[$::bitbucket::service_file_location],
        before      => Service['bitbucket'],
        path        => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      }
    }

    service { 'bitbucket':
      ensure  => $::bitbucket::service_ensure,
      enable  => $::bitbucket::service_enable,
      require => File[$::bitbucket::service_file_location],
    }
  }
}
