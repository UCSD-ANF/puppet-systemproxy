# EXPERIMENTAL: Set Darwin-specific elements up to use a proxy.
# This class should only be called from init.pp
class systemproxy::darwin {

  include stdlib

  # Always set proxybypassdomains to something.
  # Either Mac defaults or something we set.
  $bypass_defaults = ['*.local','169.254/16']
  $bypass_arr      = $systemproxy::ensure ? {
    'present' => $systemproxy::no_proxy,
    'absent'  => $bypass_defaults,
  }

  $networksetup = '/usr/sbin/networksetup'
  $service = $systemproxy::networkservice

  $setarg = join(suffix(prefix($bypass_arr,'\''),'\''),' ')
  $getarg = join(suffix(prefix($bypass_arr,'-e \''),'\''),' ')

  $setargs = "${service} Empty ${setarg}"
  $getargs = "${service} | fgrep -v ${getarg}"

  exec { "${networksetup} -setproxybypassdomains ${setargs}":
    onlyif => "${networksetup} -getproxybypassdomains ${getargs}",
  }

  # Based on the command
  # `networksetup -printcommands | awk '{ if ($2 ~ "^-set.+proxy$") print $2}'`
  # ... which shows:
  # -setftpproxy
  # -setwebproxy
  # -setsecurewebproxy
  # -setstreamingproxy      # unmanaged
  # -setgopherproxy
  # -setsocksfirewallproxy  # unmanaged
  $proxy_svc = [ 'ftp', 'gopher', 'web', 'secureweb', ]

  if $systemproxy::ensure == 'present' {
    systemproxy::darwin::set { $proxy_svc :
      host    => $systemproxy::host,
      port    => $systemproxy::port,
      service => $service,
      state   => 'on',
    }
  } elsif $systemproxy::ensure == 'absent' {
    systemproxy::darwin::set { $proxy_svc :
      service => $service,
    }
  }
}
