# == Class bitbucket::params
#
class bitbucket::params {
  case $::osfamily {
    'Debian': {
      $json_packages           = [ 'rubygem-json', 'ruby-json' ]
      $service_lockfile        = '/var/lock/bitbucket'
      if $::operatingsystemmajrelease == '8' {
        $service_file_location = '/lib/systemd/system/bitbucket.service'
        $service_file_template = 'bitbucket/bitbucket.service.erb'
      } elsif $::operatingsystemmajrelease =~ /^7$|^14.04$/ {
        $service_file_location = '/etc/init.d/bitbucket'
        $service_file_template = 'bitbucket/bitbucket.initscript.erb'
        $service_status        = 'status_of_proc'
      } else {
        fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
      }
    }
    'RedHat', 'Amazon': {
      $service_lockfile        = '/var/lock/subsys/bitbucket'
      if $::operatingsystemmajrelease == '7' {
        $json_packages         = 'rubygem-json'
        $service_file_location = '/usr/lib/systemd/system/bitbucket.service'
        $service_file_template = 'bitbucket/bitbucket.service.erb'
      } elsif $::operatingsystemmajrelease == '6' {
        $lsb_package           = 'redhat-lsb'
        $json_packages         = [ 'rubygem-json', 'ruby-json' ]
        $service_file_location = '/etc/init.d/bitbucket'
        $service_file_template = 'bitbucket/bitbucket.initscript.erb'
        $service_status        = 'status'
      } else {
        fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
