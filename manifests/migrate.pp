# == Class bitbucket::migrate
#
# This class is called from bitbucket for migrating from Stash.
#
class bitbucket::migrate {
  if $::bitbucket::migrate_from_stash {
    exec { 'shutdown_stash':
      command => $::bitbucket::migrate_stop,
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      onlyif  => "/bin/ps -u ${::bitbucket::migrate_user}",
    }

    exec { 'move_homedir':
      command => "/bin/mv ${::bitbucket::migrate_homedir} ${::bitbucket::homedir}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates => $::bitbucket::homedir,
      onlyif  => "test -d ${::bitbucket::migrate_homedir}",
      unless  => "/bin/ps -u ${::bitbucket::migrate_user}",
      require => Exec['shutdown_stash'],
    }

    if $::bitbucket::manage_usr_grp {
      exec { 'group_migrate':
        command => "groupmod -n ${::bitbucket::group} ${::bitbucket::migrate_group}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "cat /etc/group | grep ^${::bitbucket::migrate_group}",
        unless  => "/bin/ps -u ${::bitbucket::migrate_user}",
        require => Exec['shutdown_stash'],
      }

      exec { 'user_migrate':
        command => "usermod -l ${::bitbucket::user} ${::bitbucket::migrate_user}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "cat /etc/passwd | grep ^${::bitbucket::migrate_user}",
        unless  => "/bin/ps -u ${::bitbucket::migrate_user}",
        require => Exec['shutdown_stash'],
      }
    }
  }
}
