# Parameters/defaults for proxy.
class systemproxy::params {

  include stdlib

  $ensure='present'

  $manage_profile_d = $::kernel ? {
    /(Darwin|FreeBSD|Solaris)/ => true,
    default                    => false,
  }

  $no_proxy_domains=['localhost*','*.local','*.localdomain']
  $no_proxy_nets=['169.254.0.0/16','127.0.0.0/8']

  $port='3128'

  $proto='http'

  $gsettings=true
  $puppet=false
  $wget=true

  $pac_basedir  = "/opt/puppet-${module_name}"
  $pac  = "${pac_basedir}/etc/proxy.pac"
  $wpad = "${pac_basedir}/etc/wpad.dat"
  $pac_uri  = "file://${pac}"
  $wpad_uri = "file://${wpad}"

  $owner = 0
  $group = 0
  $mode = '0644'
  $dir_mode = '0755'

  $puppet_conf = $::kernel ? {
    'FreeBSD' => '/usr/local/etc/puppet/puppet.conf',
    'Darwin'  => '/etc/puppet/puppet.conf',
    default   => '/etc/puppetlabs/puppet/puppet.conf',
  }

  $shell_proto = flatten( [
    ['all_proxy','ftp_proxy','http_proxy','https_proxy'],
    ['ALL_PROXY','FTP_PROXY','HTTP_PROXY','HTTPS_PROXY'],
  ])

  # Assuming Homebrew for Darwin.
  $wgetrc = $::kernel ? {
    /(Darwin|FreeBSD)/ => '/usr/local/etc/wgetrc',
    default            => '/etc/wgetrc',
  }
}
