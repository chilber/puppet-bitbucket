# == Class bitbucket::migrate
#
# This class is called from bitbucket for migrating from Stash.
#
class bitbucket::migrate {
  if $::bitbucket::migrate_from_stash {
    exec { 'shutdown_stash':
      command => $::bitbucket::migrate_stop,
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      onlyif  => "ps -u ${::bitbucket::migrate_user}",
    }

    exec { 'move_homedir':
      command => "mv ${::bitbucket::migrate_homedir} ${::bitbucket::homedir}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates => $::bitbucket::homedir,
      onlyif  => "test -d ${::bitbucket::migrate_homedir}",
      unless  => "ps -u ${::bitbucket::migrate_user}",
      require => Exec['shutdown_stash'],
    }

    exec { 'move_stash_config':
      command => "mv ${::bitbucket::homedir}/shared/stash-config.properties ${::bitbucket::homedir}/shared/stash-config.properties.bak",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates => "${::bitbucket::homedir}/shared/stash-config.properties.bak",
      onlyif  => "test -e ${::bitbucket::homedir}/shared/stash-config.properties",
      unless  => "ps -u ${::bitbucket::migrate_user}",
      require => Exec['move_homedir'],
    }

    if $::bitbucket::manage_usr_grp {
      exec { 'group_migrate':
        command => "groupmod -n ${::bitbucket::group} ${::bitbucket::migrate_group}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "cat /etc/group | grep ^${::bitbucket::migrate_group}",
        unless  => "ps -u ${::bitbucket::migrate_user}",
        require => Exec['shutdown_stash'],
      }

      exec { 'user_migrate':
        command => "usermod -l ${::bitbucket::user} ${::bitbucket::migrate_user}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "cat /etc/passwd | grep ^${::bitbucket::migrate_user}",
        unless  => "ps -u ${::bitbucket::migrate_user}",
        require => Exec['shutdown_stash'],
      }
    }
  }
}
