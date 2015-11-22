require 'spec_helper'

describe 'bitbucket' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "bitbucket class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('bitbucket::params') }
          it { is_expected.to contain_class('bitbucket::install').that_comes_before('bitbucket::config') }
          it { is_expected.to contain_class('bitbucket::config') }
          it { is_expected.to contain_class('bitbucket::service').that_subscribes_to('bitbucket::config') }

        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'bitbucket class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('bitbucket') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
