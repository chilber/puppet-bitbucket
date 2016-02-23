require 'spec_helper_acceptance'

download_url = ENV['download_url'] if ENV['download_url']
if ENV['download_url']
  download_url = ENV['download_url']
else
  download_url = 'undef'
end
if download_url != 'undef'
  java_url = download_url
else
  download_url = 'http://www.atlassian.com/software/stash/downloads/binary'
  java_url = "http://download.oracle.com/otn-pub/java/jdk/8u73-b02/"
end

describe 'bitbucket class' do
  context 'default parameters' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      file { '/opt/java': ensure => directory } ->
      staging::file { 'jdk-8u73-linux-x64.tar.gz':
        source => '#{java_url}/jdk-8u73-linux-x64.tar.gz',
        timeout => '1800',
        curl_option => '--header "Cookie: oraclelicense=accept-securebackup-cookie"',
      } ->
      staging::extract { 'jdk-8u73-linux-x64.tar.gz':
        target => '/opt/java',
        creates => '/opt/java/bin/java',
        strip => '1',
      } ->
      class { 'bitbucket':
        download_url  => '#{download_url}',
        javahome      => '/opt/java',
        license       => 'AAABLw0ODAoPeNptkE1rwkAQhu/7KxZ6aQ8ryfoRERaqSSjSxJRoSw+9rMtYF/MhsxNb++sbG4uleBgY5uN5552bVQM8M8RlwP1g0pcTr8/DaMWl5w9ZBM6g3ZOtKzWztG7MDojfLgEPgHdvEx4fdNHoU5+FCD9JpAnUaVv4npBjFtYVaUNxqm2hSkC0RPc71Lv6w9IXYM/UJbtwFGEDzJF22167Zg/QVQproHLwAuhOU5K1vIqg0pWB+HNv8fhH2BdyxDJ815V1HTXthPnjRfgsknTg1XEPC12CCrM0jfNwPk1Y53MeqVkQPYggy6cimqavYpwPQ7aMF6oNkYwCzx8MJDuD2vFkHl3rXD+zu2JJGglQbXThfu0vmnINmG2eXWtaCZ89NWi22sH/F38D+heU9jAsAhRzwj0ZMcWaXhhdIX+OCg7nkclBOgIUZquqAoEy4BoxUU5FVWYAUektn8Y=X02f7',
        dburl         => 'jdbc:hsqldb:/home/bitbucket/data/db;shutdown=true',
        dbdriver      => 'org.hsqldb.jdbcDriver',
      } ->
      class { 'bitbucket::facts': }
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

    describe command('curl -L http://localhost:7990') do
      its(:stdout) { should match(/Git repository management/) }
    end

   describe command('facter -p bitbucket_version') do
     its(:stdout) { should match(/4\.3\.2/) }
   end
  end
end
