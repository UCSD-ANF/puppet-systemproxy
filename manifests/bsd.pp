# Set (Free?)BSD-specific elements up to use a proxy.
# This class should only be called from init.pp
class systemproxy::bsd {

  # make.conf
  systemproxy::entry { $systemproxy::shell_proto :
    ensure => $systemproxy::ensure,
    path   => '/etc/make.conf',
    value  => $systemproxy::proxy,
  }
  if $systemproxy::no_proxy != false {
    systemproxy::entry { [ 'no_proxy', 'NO_PROXY' ]:
      ensure  => $systemproxy::ensure,
      path    => '/etc/make.conf',
      value   => $systemproxy::no_proxy,
    }
  }
}
