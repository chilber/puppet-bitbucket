require 'spec_helper'

describe 'bitbucket::facts' do
  context 'bitbucket::facts class without any parameters on Puppet Open Source' do
    context 'on Debian' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
          :puppetversion             => '',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('bitbucket::facts') }

      it { is_expected.to contain_file('/etc/facter').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/facter/facts.d').with_ensure('directory') }
      it do
        is_expected.to contain_file('/etc/facter/facts.d/bitbucket_facts.rb').with(
          'ensure' => 'present',
          'mode'   => '0500',
        ).with_content(
          /url = \'http:\/\/127.0.0.1:7990\/rest\/api\/1.0\/application-properties\'/
        )
      end
    end
    context 'on RedHat 6' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
          :puppetversion             => '',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('bitbucket::facts') }

      it { is_expected.to contain_file('/etc/facter').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/facter/facts.d').with_ensure('directory') }
      it { is_expected.to contain_package('ruby-json').with_ensure('present') }
      it { is_expected.to contain_package('rubygem-json').with_ensure('present') }
      it do
        is_expected.to contain_file('/etc/facter/facts.d/bitbucket_facts.rb').with(
          'ensure' => 'present',
          'mode'   => '0500',
        ).with_content(
          /url = \'http:\/\/127.0.0.1:7990\/rest\/api\/1.0\/application-properties\'/
        )
      end
    end
    context 'on RedHat 7' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '7',
          :puppetversion             => '',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('bitbucket::facts') }

      it { is_expected.to contain_file('/etc/facter').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/facter/facts.d').with_ensure('directory') }
      it { is_expected.to contain_package('rubygem-json').with_ensure('present') }
      it { is_expected.not_to contain_package('ruby-json') }
      it do
        is_expected.to contain_file('/etc/facter/facts.d/bitbucket_facts.rb').with(
          'ensure' => 'present',
          'mode'   => '0500',
        ).with_content(
          /url = \'http:\/\/127.0.0.1:7990\/rest\/api\/1.0\/application-properties\'/
        )
      end
    end
  end
  context 'bitbucket::facts class without any parameters on Puppet Enterprise' do
    context 'on Debian' do
      let(:facts) do
        {
          :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '7',
          :puppetversion             => 'Puppet Enterprise 2015.whatever',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('bitbucket::facts') }

      it { is_expected.to contain_file('/etc/puppetlabs/facter').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d').with_ensure('directory') }
      it do
        is_expected.to contain_file('/etc/puppetlabs/facter/facts.d/bitbucket_facts.rb').with(
          'ensure' => 'present',
          'mode'   => '0500',
        ).with_content(
          /url = \'http:\/\/127.0.0.1:7990\/rest\/api\/1.0\/application-properties\'/
        )
      end
    end
    context 'on RedHat 6' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
          :puppetversion             => 'Puppet Enterprise 2015.whatever',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('bitbucket::facts') }

      it { is_expected.to contain_file('/etc/puppetlabs/facter').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d').with_ensure('directory') }
      it do
        is_expected.to contain_file('/etc/puppetlabs/facter/facts.d/bitbucket_facts.rb').with(
          'ensure' => 'present',
          'mode'   => '0500',
        ).with_content(
          /url = \'http:\/\/127.0.0.1:7990\/rest\/api\/1.0\/application-properties\'/
        )
      end
      it { is_expected.not_to contain_package('ruby-json') }
      it { is_expected.not_to contain_package('rubygem-json') }
    end
    context 'on RedHat 7' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '7',
          :puppetversion             => 'Puppet Enterprise 2015.whatever',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('/etc/puppetlabs/facter').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d').with_ensure('directory') }
      it do
        is_expected.to contain_file('/etc/puppetlabs/facter/facts.d/bitbucket_facts.rb').with(
          'ensure' => 'present',
          'mode'   => '0500',
        ).with_content(
          /url = \'http:\/\/127.0.0.1:7990\/rest\/api\/1.0\/application-properties\'/
        )
      end
      it { is_expected.not_to contain_package('rubygem-json') }
      it { is_expected.not_to contain_package('ruby-json') }
    end
  end
end
