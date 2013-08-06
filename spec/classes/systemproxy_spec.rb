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
          :host             => 'proxy.example.com',
          :no_proxy_domains => [ '*.example.com', 'some.host.com' ],
          :no_proxy_nets    => [ '169.254.0.0/16' ]
        }}
        it { should contain_file('/etc/profile.d/proxy.csh').with_content(
          /NO_PROXY "\*\.example\.com,some\.host\.com,169\.254\.0\.0\/16"/
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
      when 'Darwin' then
        context "and OS family is #{oses[os][:osfamily]}" do
          let(:params){{
            :host     => 'proxy.example.com',
            :no_proxy_domains => [ '*.example.com', 'some.host.com' ],
            :no_proxy_nets    => [ '169.254.0.0/16' ]
          }}
          it { should contain_exec(
            '/usr/sbin/networksetup -setsecurewebproxy Ethernet proxy.example.com 3128 off'
          )}
          it { should contain_exec(
            '/usr/sbin/networksetup -setproxybypassdomains Ethernet Empty \'*.example.com\' \'some.host.com\' \'169.254.0.0/16\''
          ).with_onlyif(
            /fgrep -v -e '\*\.example.com' -e 'some\.host\.com' -e '169\.254\.0\.0\/16'/
          )}
        end
      when 'FreeBSD' then
        context "and OS family is #{oses[os][:osfamily]}" do
          let(:params){{ :host => 'proxy.example.com', }}

          it { should contain_file_line(
            'export FTP_PROXY entry for /etc/make.conf').with_line(
            'export FTP_PROXY=http://proxy.example.com:3128/'
          )}
        end
      when 'RedHat' then
        context "and OS family is #{oses[os][:osfamily]}" do
          let(:params){{ :host => 'proxy.example.com', }}

          it { should contain_file_line('RPM %_httpproxy').with_line(
            '%_httpproxy proxy.example.com'
          )}
          it { should contain_file_line('RPM %_httpport').with_line(
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
