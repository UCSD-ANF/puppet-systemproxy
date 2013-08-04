# Set puppet to use a proxy.
# Requires a proxy that will allow us to talk to port 8140 via CONNECT.
# By default, Squid won't allow SSL connections to any port but 443.
# This class should only be called from init.pp
class systemproxy::puppet {

  validate_bool($systemproxy::puppet)

  $puppet_ensure = $systemproxy::puppet ? {
    true  => $systemproxy::ensure,
    false => 'absent',
  }
  systemproxy::entry { 'proxy_host':
    ensure => $puppet_ensure,
    path   => $systemproxy::puppet_conf,
    prefix => '    ',
    value  => $systemproxy::host,
  }
  systemproxy::entry { 'proxy_port':
    ensure => $puppet_ensure,
    path   => $systemproxy::puppet_conf,
    prefix => '    ',
    value  => $systemproxy::port,
  }
}
