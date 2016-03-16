require 'spec_helper'

describe 'bitbucket' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'bitbucket class without any parameters' do
          it { is_expected.to compile.with_all_deps }

          # Class tests
          it { is_expected.to contain_class('bitbucket::params') }
          it { is_expected.to contain_class('bitbucket::install').that_comes_before('bitbucket::config') }
          it { is_expected.to contain_class('bitbucket::config') }
          it { is_expected.to contain_class('bitbucket::service').that_subscribes_to('bitbucket::config') }

          # Install tests
          it { is_expected.not_to contain_exec('shutdown_stash') }
          it { is_expected.not_to contain_exec('move_homedir') }
          it { is_expected.not_to contain_exec('move_stash_config') }
          it { is_expected.not_to contain_exec('group_migrate') }
          it { is_expected.not_to contain_exec('user_migrate') }
          it { is_expected.to contain_group('bitbucket') }
          it { is_expected.to contain_user('bitbucket') }
          it { is_expected.to contain_file('/opt/bitbucket') }
          it { is_expected.to contain_file('/home/bitbucket') }
          it { is_expected.to contain_archive('/tmp/atlassian-bitbucket-4.3.2.tar.gz') }
          it { is_expected.to contain_file('/home/bitbucket/shared') }
          it { is_expected.to contain_file('/var/tmp/.bitbucket.yaml') }
          it { is_expected.to contain_file('/home/bitbucket/shared/bitbucket.properties') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.baseUrl') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.displayName') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.license') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.sysadmin.displayName') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.sysadmin.emailAddress') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.sysadmin.password') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  setup.sysadmin.username') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  jdbc.driver') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  jdbc.password') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  jdbc.url') }
          it { is_expected.to contain_ini_setting('/home/bitbucket/shared/bitbucket.properties  jdbc.user') }
          it { is_expected.to contain_exec('chown_/opt/bitbucket/atlassian-bitbucket-4.3.2') }

          # Config tests
          it { is_expected.to contain_file('/opt/bitbucket/atlassian-bitbucket-4.3.2/conf/server.xml') }
          it { is_expected.to contain_file_line('bitbucket_java_home') }
          it { is_expected.to contain_file_line('bitbucket_home') }
          it { is_expected.to contain_file_line('bitbucket_umask') }
          it { is_expected.to contain_ini_setting('bitbucket_jvm_minimum_memory') }
          it { is_expected.to contain_ini_setting('bitbucket_jvm_maximum_memory') }
          it { is_expected.to contain_ini_setting('bitbucket_user') }
          it { is_expected.to contain_ini_setting('bitbucket_shell') }
          it { is_expected.to contain_ini_setting('bitbucket_httpport') }

          # Service tests
          it { is_expected.to contain_service('bitbucket') }
        end

        context 'bitbucket class with custom parameters' do
          let(:params) do
            {
              'javahome'                     => '/etc/alternatives/java',
              'jvm_minimum_memory'           => '1G',
              'jvm_maximum_memory'           => '3G',
              'jvm_support_recommended_args' => '-XX:-HeapDumpOnOutOfMemoryError',
              'version'                      => '4.0.2',
              'checksum'                     => '25bc382ea55de3d5fd5427edd54535ab',
              'product'                      => 'new-bitbucket-name',
              'format'                       => 'tgz',
              'installdir'                   => '/path/to/bitbucket/install',
              'homedir'                      => '/path/to/bitbucket/home',
              'context_path'                 => '/bitbucket',
              'tomcat_port'                  => 7991,
              'user'                         => 'custom_user',
              'group'                        => 'custom_group',
              'uid'                          => '1234',
              'gid'                          => '5678',
              'display_name'                 => 'Custom Bitbucket Name',
              'base_url'                     => 'https://my.bitbucket.url',
              'license'                      => 'MY_BIG_GIANT_ATLASSIAN_LICENSE_KEY',
              'sysadmin_username'            => 'custom_admin',
              'sysadmin_password'            => 'custom_pass',
              'sysadmin_name'                => 'My Cool Admin Account',
              'sysadmin_email'               => 'admin@email.com',
              'config_properties' => {
                'custom_property_1' => 'custom_value_1',
                'custom_property_2' => 'custom_value_2',
              },
              'dbuser'                       => 'custom_db_user',
              'dbpassword'                   => 'custom_password',
              'dburl'                        => 'jdbc:hsqldb:/path/to/bitbucket/home/data/db;shutdown=true',
              'dbdriver'                     => 'org.hsqldb.jdbcDriver',
              'download_url'                 => 'http://my.custom.server/path/to/download',
              'stop_bitbucket'               => 'service bitbucket stop && sleep 30',
              'service_manage'               => false,
              'proxy' => {
                'scheme'    => 'https',
                'proxyName' => 'my.proxy.url',
                'proxyPort' => '443',
              },
            }
          end
          it { is_expected.to compile.with_all_deps }

          # Install tests
          it do
            is_expected.to contain_group('custom_group').with(
              'ensure' => 'present',
              'gid'    => '5678',
            )
          end
          it do
            is_expected.to contain_user('custom_user').with(
              'ensure'           => 'present',
              'comment'          => 'Bitbucket daemon account',
              'shell'            => '/bin/bash',
              'home'             => '/path/to/bitbucket/home',
              'password'         => '*',
              'password_min_age' => '0',
              'password_max_age' => '99999',
              'managehome'       => true,
              'uid'              => '1234',
              'gid'              => '5678',
            ).that_comes_before(
              'File[/path/to/bitbucket/install]'
            ).that_comes_before(
              'File[/path/to/bitbucket/home]'
            )
          end
          it do
            is_expected.to contain_file('/path/to/bitbucket/install').with(
              'ensure' => 'directory',
              'owner'  => 'custom_user',
              'group'  => 'custom_group',
            )
          end
          it do
            is_expected.to contain_file('/path/to/bitbucket/home').with(
              'ensure' => 'directory',
              'owner'  => 'custom_user',
              'group'  => 'custom_group',
            )
          end
          it do
            is_expected.to contain_archive('/tmp/atlassian-new-bitbucket-name-4.0.2.tgz').with(
              'ensure'        => 'present',
              'extract'       => true,
              'extract_path'  => '/path/to/bitbucket/install',
              'source'        => 'http://my.custom.server/path/to/download/atlassian-new-bitbucket-name-4.0.2.tgz',
              'creates'       => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2',
              'cleanup'       => true,
              'checksum_type' => 'md5',
              'checksum'      => '25bc382ea55de3d5fd5427edd54535ab',
              'user'          => 'custom_user',
              'group'         => 'custom_group',
            ).that_notifies(
              'Exec[chown_/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2]'
            ).that_requires(
              'File[/path/to/bitbucket/install]'
            ).that_requires(
              'User[custom_user]'
            )
          end
          it do
            is_expected.to contain_file('/path/to/bitbucket/home/shared').with(
              'ensure' => 'directory',
              'owner'  => 'custom_user',
              'group'  => 'custom_group',
              'mode'   => '0700',
            )
          end
          it do
            is_expected.to contain_file('/var/tmp/.bitbucket.yaml').with(
              'ensure'  => 'file',
              'owner'   => 'custom_user',
              'group'   => 'custom_group',
              'mode'    => '0700',
              'content' => /properties_file: \/path\/to\/bitbucket\/home\/shared\/bitbucket.properties\nport: 7991/
            )
          end
          it do
            is_expected.to contain_file('/path/to/bitbucket/home/shared/bitbucket.properties').with(
              'ensure' => 'file',
              'owner'  => 'custom_user',
              'group'  => 'custom_group',
              'mode'   => '0640',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.baseUrl').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.baseUrl',
              'value'   => 'https://my.bitbucket.url',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.displayName').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.displayName',
              'value'   => 'Custom Bitbucket Name',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.license').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.license',
              'value'   => 'MY_BIG_GIANT_ATLASSIAN_LICENSE_KEY',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.sysadmin.displayName').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.sysadmin.displayName',
              'value'   => 'My Cool Admin Account',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.sysadmin.emailAddress').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.sysadmin.emailAddress',
              'value'   => 'admin@email.com',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.sysadmin.password').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.sysadmin.password',
              'value'   => 'custom_pass',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  setup.sysadmin.username').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'setup.sysadmin.username',
              'value'   => 'custom_admin',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  jdbc.driver').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'jdbc.driver',
              'value'   => 'org.hsqldb.jdbcDriver',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  jdbc.password').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'jdbc.password',
              'value'   => 'custom_password',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  jdbc.url').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'jdbc.url',
              'value'   => 'jdbc:hsqldb:/path/to/bitbucket/home/data/db;shutdown=true',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  jdbc.user').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'jdbc.user',
              'value'   => 'custom_db_user',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  custom_property_1').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'custom_property_1',
              'value'   => 'custom_value_1',
            )
          end
          it do
            is_expected.to contain_ini_setting('/path/to/bitbucket/home/shared/bitbucket.properties  custom_property_2').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/home/shared/bitbucket.properties',
              'section' => '',
              'setting' => 'custom_property_2',
              'value'   => 'custom_value_2',
            )
          end
          it do
            is_expected.to contain_exec('chown_/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2').with(
              'command'     => '/bin/chown -R custom_user:custom_group /path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2',
              'refreshonly' => true,
            )
          end

          # Config tests
          it do
            is_expected.to contain_file('/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/conf/server.xml').with(
              'ensure'  => 'present',
              'owner'   => 'custom_user',
              'group'   => 'custom_group',
              'mode'    => '0640',
            # v there's probably an easier way to do this v
            ).with_content(
              /Connector port=\"7991\"/
            ).with_content(
              /scheme=\"https\"/
            ).with_content(
              /proxyName=\"my.proxy.url\"/
            ).with_content(
              /proxyPort=\"443\"/
            ).with_content(
              /path=\"\/bitbucket\"/
            )
          end
          it do
            is_expected.to contain_file_line('bitbucket_java_home').with(
              'ensure' => 'present',
              'path'   => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/setenv.sh',
              'line'   => '  export JAVA_HOME=/etc/alternatives/java',
              'match'  => 'export JAVA_HOME=',
            )
          end
          it do
            is_expected.to contain_file_line('bitbucket_home').with(
              'ensure' => 'present',
              'path'   => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/setenv.sh',
              'line'   => '  export BITBUCKET_HOME=/path/to/bitbucket/home',
              'match'  => 'export BITBUCKET_HOME=',
            )
          end
          it do
            is_expected.to contain_file_line('bitbucket_umask').with(
              'ensure' => 'present',
              'path'   => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/setenv.sh',
              'line'   => 'umask 0027',
              'match'  => '^# umask 0027$',
            )
          end
          it do
            is_expected.to contain_ini_setting('bitbucket_jvm_minimum_memory').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/setenv.sh',
              'section' => '',
              'setting' => 'JVM_MINIMUM_MEMORY',
              'value'   => '1G',
            )
          end
          it do
            is_expected.to contain_ini_setting('bitbucket_jvm_maximum_memory').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/setenv.sh',
              'section' => '',
              'setting' => 'JVM_MAXIMUM_MEMORY',
              'value'   => '3G',
            )
          end
          it do
            is_expected.to contain_ini_setting('bitbucket_user').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/user.sh',
              'section' => '',
              'setting' => 'BITBUCKET_USER',
              'value'   => 'custom_user',
            )
          end
          it do
            is_expected.to contain_ini_setting('bitbucket_shell').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/bin/user.sh',
              'section' => '',
              'setting' => 'SHELL',
              'value'   => '/bin/bash',
            )
          end
          it do
            is_expected.to contain_ini_setting('bitbucket_httpport').with(
              'ensure'  => 'present',
              'path'    => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2/conf/scripts.cfg',
              'section' => '',
              'setting' => 'bitbucket_httpport',
              'value'   => '7991',
            )
          end
          it { is_expected.not_to contain_service('bitbucket') }
        end
      end
    end
  end

  context 'when using staging' do
    context 'with defaults' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
        }
      end
      let(:params) do
        {
          'deploy_module' => 'staging',
        }
      end
      it { is_expected.to contain_staging__file('atlassian-bitbucket-4.3.2.tar.gz') }
      it { is_expected.to contain_staging__extract('atlassian-bitbucket-4.3.2.tar.gz') }
    end
    context 'with parameter overrides' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
        }
      end
      let(:params) do
        {
          'deploy_module' => 'staging',
          'version'       => '4.0.2',
          'product'       => 'new-bitbucket-name',
          'format'        => 'tgz',
          'installdir'    => '/path/to/bitbucket/install',
          'homedir'       => '/path/to/bitbucket/home',
          'user'          => 'custom_user',
          'group'         => 'custom_group',
          'download_url'  => 'http://my.custom.server/path/to/download',
        }
      end
      it do
        is_expected.to contain_staging__file('atlassian-new-bitbucket-name-4.0.2.tgz').with(
          'source'  => 'http://my.custom.server/path/to/download/atlassian-new-bitbucket-name-4.0.2.tgz',
          'timeout' => 1800,
        ).that_comes_before('Staging::Extract[atlassian-new-bitbucket-name-4.0.2.tgz]')
      end
      it do
        is_expected.to contain_staging__extract('atlassian-new-bitbucket-name-4.0.2.tgz').with(
          'target'  => '/path/to/bitbucket/install',
          'creates' => '/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2',
          'user'    => 'custom_user',
          'group'   => 'custom_group',
        ).that_notifies(
          'Exec[chown_/path/to/bitbucket/install/atlassian-new-bitbucket-name-4.0.2]'
        ).that_requires(
          'File[/path/to/bitbucket/install]'
        ).that_requires(
          'User[custom_user]'
        )
      end
    end
  end

  context 'when managing the service' do
    context 'bitbucket class without any parameters' do
      context 'on Debian 7' do
        let(:facts) do
          {
            :osfamily                  => 'Debian',
            :operatingsystemmajrelease => '7',
          }
        end

        it do
          is_expected.to contain_file('/etc/init.d/bitbucket').with_content(
            /status_of_proc -p \$PIDFILE \"\${NAME}\" $NAME && exit 0 || exit \$?/
          )
        end
      end
      context 'on Debian 8' do
        let(:facts) do
          {
            :osfamily                  => 'Debian',
            :operatingsystemmajrelease => '8',
          }
        end

        it { is_expected.to contain_file('/usr/lib/systemd/system/bitbucket.service') }
        it { is_expected.to contain_exec('refresh_systemd') }
      end
      context 'on RedHat 6' do
        let(:facts) do
          {
            :osfamily                  => 'RedHat',
            :operatingsystemmajrelease => '6',
          }
        end

        it do
          is_expected.to contain_file('/etc/init.d/bitbucket').with_content(
            /status -p \$PIDFILE \"\${NAME}\" $NAME && exit 0 || exit \$?/
          )
        end
        it { is_expected.to contain_package('redhat-lsb') }
      end
      context 'on RedHat 7' do
        let(:facts) do
          {
            :osfamily                  => 'RedHat',
            :operatingsystemmajrelease => '7',
          }
        end

        it { is_expected.to contain_file('/usr/lib/systemd/system/bitbucket.service') }
        it { is_expected.to contain_exec('refresh_systemd') }
      end
      context 'on Ubuntu 14.04' do
        let(:facts) do
          {
            :osfamily                  => 'Debian',
            :operatingsystemmajrelease => '14.04',
          }
        end

        it do
          is_expected.to contain_file('/etc/init.d/bitbucket').with_content(
            /status_of_proc -p \$PIDFILE \"\${NAME}\" $NAME && exit 0 || exit \$?/
          )
        end
      end
    end
    context 'bitbucket class with parameter overrides' do
      let(:params) do
        {
          'javahome'       => '/etc/alternatives/java',
          'version'        => '4.0.2',
          'product'        => 'new-bitbucket-name',
          'format'         => 'tgz',
          'installdir'     => '/path/to/bitbucket/install',
          'homedir'        => '/path/to/bitbucket/home',
          'user'           => 'custom_user',
          'service_ensure' => 'stopped',
          'service_enable' => false,
        }
      end
      context 'when not using systemd' do
        let(:facts) do
          {
            :osfamily                  => 'Debian',
            :operatingsystemmajrelease => '7',
          }
        end

        it do
          is_expected.to contain_file('/etc/init.d/bitbucket').with(
            'mode' => '0755',
          ).with_content(
            /RUNUSER=custom_user/
          ).with_content(
            /BITBUCKET_INSTALLDIR=\"\/path\/to\/bitbucket\/install\/atlassian-new-bitbucket-name-4.0.2\"/
          ).with_content(
            /BITBUCKET_HOME=\"\/path\/to\/bitbucket\/home\"/
          )
        end
        it do
          is_expected.to contain_service('bitbucket').with(
            'ensure' => 'stopped',
            'enable' => false,
          )
        end
      end
      context 'when using systemd' do
        let(:facts) do
          {
            :osfamily                  => 'Debian',
            :operatingsystemmajrelease => '8',
          }
        end

        it do
          is_expected.to contain_file('/usr/lib/systemd/system/bitbucket.service').with(
            'mode' => '0755',
          ).with_content(
            /JAVA_HOME=\/etc\/alternatives\/java/
          ).with_content(
            /PIDFile=\/path\/to\/bitbucket\/install\/atlassian-new-bitbucket-name-4.0.2\/work\/catalina.pid/
          ).with_content(
            /User=custom_user/
          ).with_content(
            /ExecStart=\/path\/to\/bitbucket\/install\/atlassian-new-bitbucket-name-4.0.2\/bin\/start-new-bitbucket-name.sh/
          ).with_content(
            /ExecStop=\/path\/to\/bitbucket\/install\/atlassian-new-bitbucket-name-4.0.2\/bin\/stop-new-bitbucket-name.sh/
          )
        end
        it do
          is_expected.to contain_exec('refresh_systemd').with(
            'command'     => 'systemctl daemon-reload',
            'refreshonly' => true,
            'path'        => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
          ).that_subscribes_to(
            'File[/usr/lib/systemd/system/bitbucket.service]'
          ).that_comes_before('Service[bitbucket]')
        end
        it do
          is_expected.to contain_service('bitbucket').with(
            'ensure' => 'stopped',
            'enable' => false,
          )
        end
      end
    end
  end

  context 'when migrating from stash' do
    context 'bitbucket class without any parameters' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
        }
      end
      let(:params) do
        {
          'migrate_from_stash' => true,
        }
      end
      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_notify('Attempting to upgrade from Stash') }
      it { is_expected.to contain_class('bitbucket::migrate') }
      it { is_expected.to contain_exec('shutdown_stash') }
      it { is_expected.to contain_exec('move_homedir') }
      it { is_expected.to contain_exec('move_stash_config') }
      it { is_expected.to contain_exec('group_migrate') }
      it { is_expected.to contain_exec('user_migrate') }
    end
    context 'bitbucket class with parameter overrides' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
        }
      end
      let(:params) do
        {
          'installdir'         => '/path/to/bitbucket/install',
          'homedir'            => '/path/to/bitbucket/home',
          'product'            => 'new-bitbucket-name',
          'version'            => '4.0.2',
          'format'             => 'tgz',
          'user'               => 'custom_user',
          'group'              => 'custom_group',
          'migrate_from_stash' => true,
          'migrate_homedir'    => '/var/stash',
          'migrate_stop'       => 'crm resource stop stash && sleep 15',
          'migrate_group'      => 'stash_group',
          'migrate_user'       => 'stash_user',
        }
      end
      it do
        is_expected.to contain_exec('shutdown_stash').with(
          'command' => 'crm resource stop stash && sleep 15',
          'onlyif'  => 'ps -u stash_user',
        )
      end
      it do
        is_expected.to contain_exec('move_homedir').with(
          'command' => 'mv /var/stash /path/to/bitbucket/home',
          'creates' => '/path/to/bitbucket/home',
          'unless'  => 'ps -u stash_user',
        ).that_requires(
          'Exec[shutdown_stash]',
        ).that_comes_before(
          'File[/path/to/bitbucket/home]'
        )
      end
      it do
        is_expected.to contain_exec('move_stash_config').with(
          'command' => 'mv /path/to/bitbucket/home/shared/stash-config.properties /path/to/bitbucket/home/shared/stash-config.properties.bak',
          'creates' => '/path/to/bitbucket/home/shared/stash-config.properties.bak',
          'onlyif'  => 'test -e /path/to/bitbucket/home/shared/stash-config.properties',
          'unless'  => 'ps -u stash_user',
        ).that_requires(
          'Exec[shutdown_stash]',
        ).that_comes_before(
          'File[/path/to/bitbucket/home]'
        )
      end
      it do
        is_expected.to contain_exec('group_migrate').with(
          'command' => 'groupmod -n custom_group stash_group',
          'onlyif'  => 'cat /etc/group | grep ^stash_group',
          'unless'  => 'ps -u stash_user',
        ).that_requires(
          'Exec[shutdown_stash]'
        ).that_comes_before(
          'Group[custom_group]'
        )
      end
      it do
        is_expected.to contain_exec('user_migrate').with(
          'command' => 'usermod -l custom_user stash_user',
          'onlyif'  => 'cat /etc/passwd | grep ^stash_user',
          'unless'  => 'ps -u stash_user',
        ).that_requires(
          'Exec[shutdown_stash]'
        ).that_comes_before(
          'User[custom_user]'
        )
      end
    end
    context 'bitbucket class when not managing user/group' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
        }
      end
      let(:params) do
        {
          'manage_usr_grp'     => false,
          'migrate_from_stash' => true,
        }
      end
      it { is_expected.to contain_exec('shutdown_stash') }
      it { is_expected.to contain_exec('move_homedir') }
      it { is_expected.not_to contain_exec('group_migrate') }
      it { is_expected.not_to contain_exec('user_migrate') }
    end
  end

  context 'when upgrading from an older version of bitbucket' do
    context 'bitbucket class without any parameters' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
          :bitbucket_version         => '4.0.2',
        }
      end

      it { is_expected.to contain_notify('Attempting to upgrade bitbucket from 4.0.2 to 4.3.2') }
      it { is_expected.to contain_exec('service bitbucket stop && sleep 15') }
    end
    context 'bitbucket class with parameter overrides' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
          :bitbucket_version         => '4.0.2',
        }
      end
      let(:params) do
        {
          'stop_bitbucket' => 'crm resource stop bitbucket && sleep 15',
        }
      end
      it do
        is_expected.to contain_exec(
          'crm resource stop bitbucket && sleep 15'
        ).that_comes_before(
          'Class[bitbucket::install]'
        )
      end
    end
  end

  context 'unsupported operating system' do
    context 'bitbucket class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_class('bitbucket') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
