require 'spec_helper'

describe 'systemproxy', :type=>'class' do

	oses = {
    'CentOS' => {
      :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat',
      :kernel          => 'Linux',
    },
    'Darwin' => {
      :operatingsystem => 'Darwin',
      :osfamily        => 'Darwin',
      :kernel          => 'Darwin',
    },
    'debian' => {
      :operatingsystem => 'debian',
      :osfamily        => 'Debian',
      :kernel          => 'Linux',
    },
    'FreeBSD' => {
      :operatingsystem => 'FreeBSD',
      :osfamily        => 'FreeBSD',
      :kernel          => 'FreeBSD',
    },
    'RedHat' => {
      :operatingsystem => 'RedHat',
      :osfamily        => 'RedHat',
      :kernel          => 'Linux',
    },
    'ubuntu' => {
      :operatingsystem => 'ubuntu',
      :osfamily        => 'Debian',
      :kernel          => 'Linux',
    }
  }
	oses.keys.each do |os|
		describe "Running on #{os}" do
      let(:facts) {{
        :operatingsystem => oses[os][:operatingsystem],
        :osfamily        => oses[os][:osfamily],
        :kernel          => oses[os][:kernel],
      }}
      let(:params){{ :host => 'proxy.example.com' }}

      it { should contain_file('/etc/profile.d/proxy.sh').with_content(
        /export HTTPS_PROXY=http:\/\/proxy.example.com:3128\//
      )}

      context "no_proxy" do
        let(:params){{
          :host     => 'proxy.example.com',
          :no_proxy => '.example.com'
        }}
        it { should contain_file('/etc/profile.d/proxy.csh').with_content(
          /setenv no_proxy ".example.com"/
        )}
      end

      context "manage_profile_d" do
        let(:params){{
          :host             => 'proxy.example.com',
          :manage_profile_d => true,
        }}
        it { should contain_file_line('enable /etc/profile.d for /etc/profile').with_line(
          'source /etc/profile.d/*.sh'
        )}
        it { should contain_file_line('enable /etc/profile.d for /etc/csh.cshrc').with_line(
          'source /etc/profile.d/*.csh'
        )}
      end

      case oses[os][:osfamily]
      when 'FreeBSD'
        context "On a #{oses[os][:operatingsystem]} system" do
          let(:params){{ :host => 'proxy.example.com', }}

          it { should contain_file_line('FTP_PROXY entry for /etc/make.conf').with_line(
            'FTP_PROXY=http://proxy.example.com:3128/'
          )}
        end
      when 'RedHat'
        context "On a #{oses[os][:operatingsystem]} system" do
          let(:params){{ :host => 'proxy.example.com', }}

          it { should contain_file_line('RPM %_ftpproxy').with_line(
            '%_httpproxy proxy.example.com'
          )}
          it { should contain_file_line('RPM %_ftpport').with_line(
            '%_httpport 3128'
          )}
          it { should contain_file_line('YUM global proxy').with_line(
            'proxy=http://proxy.example.com:3128/'
          )}
        end
      end
    end
  end
end