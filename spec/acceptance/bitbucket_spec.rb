require 'spec_helper_acceptance'

download_url = ENV['download_url'] if ENV['download_url']
if ENV['download_url']
  download_url = ENV['download_url']
else
  download_url = 'undef'
end
if download_url == 'undef'
  java_url = "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/"
else
  java_url = download_url
end

describe 'bitbucket class' do
  context 'default parameters' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      file { '/opt/java': ensure => directory } ->
      staging::file { 'jdk-8u45-linux-x64.tar.gz':
        source => '#{java_url}/jdk-8u45-linux-x64.tar.gz',
        timeout => '1800',
        wget_option => '-q -c --header "Cookie: oraclelicense=accept-securebackup-cookie"',
      } ->
      staging::extract { 'jdk-8u45-linux-x64.tar.gz':
        target => '/opt/java',
        creates => '/opt/java/bin/java',
        strip => '1',
      } ->
      class { 'bitbucket':
        download_url  => '#{download_url}',
        checksum      => '25bc382ea55de3d5fd5427edd54535ab',
        version       => '4.0.2',
        javahome      => '/opt/java',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      sleep 180
      shell 'wget -q --tries=20 --retry-connrefused --read-timeout=10 localhost:7990'
      apply_manifest(pp, :catch_changes => true)
    end

    describe process('java') do
      it { should be_running }
    end

    describe port(7990) do
      it { is_expected.to be_listening }
    end

    describe service('bitbucket') do
      it { should be_enabled }
    end

    describe user('bitbucket') do
      it { should exist }
      it { should belong_to_group 'bitbucket' }
      it { should have_login_shell '/bin/bash' }
    end

    describe command('curl http://localhost:7990') do
      its(:stdout) { should match(/Git repository management/) }
    end

#    describe command('facter -p stash_version') do
#      its(:stdout) { should match(/4\.0\.2/) }
#    end
  end
end
