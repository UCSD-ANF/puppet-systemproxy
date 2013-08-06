# Set puppet to use a proxy.
# Requires a proxy that will allow us to talk to port 8140 via CONNECT.
# By default, Squid won't allow SSL connections to any port but 443.
# This class should only be called from init.pp
class systemproxy::puppet {

  # This defaults to 'absent'.  Do not override
  # unless your proxy supports SSL on port 8140.
  $puppet_ensure = $systemproxy::puppet ? {
    true  => $systemproxy::ensure,
    false => 'absent',
  }
  file_line { 'proxy_host for puppet.conf':
    ensure => $puppet_ensure,
    path   => $systemproxy::puppet_conf,
    line   => "    proxy_host=${systemproxy::host}",
    match  => 'proxy_host',
  }
  file_line { 'proxy_port for puppet.conf':
    ensure => $puppet_ensure,
    path   => $systemproxy::puppet_conf,
    line   => "    proxy_port=${systemproxy::host}",
    match  => 'proxy_port',
  }
}
