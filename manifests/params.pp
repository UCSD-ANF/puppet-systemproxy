# Parameters/defaults for proxy.
class systemproxy::params {

  include stdlib

  $ensure='present'

  $manage_profile_d = $::kernel ? {
    /(Darwin|FreeBSD|Solaris)/ => true,
    default                    => false,
  }

  $no_proxy=[]

  $port='3128'

  $proto='http'

  $puppet=false

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
