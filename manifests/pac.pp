# Create Proxy Auto-Config (PAC) file
# See https://en.wikipedia.org/wiki/Proxy_auto-config
class systemproxy::pac {

  include systemproxy::params

  File {
    owner => $systemproxy::params::owner,
    group => $systemproxy::params::group,
    mode  => $systemproxy::params::mode,
  }

  # Template vars.
  $alertOn          = $systemproxy::alertOn
  $basedir          = $systemproxy::params::pac_basedir
  $host             = $systemproxy::host
  $port             = $systemproxy::port
  $no_proxy_domains = $systemproxy::no_proxy_domains
  $no_proxy_nets    = $systemproxy::no_proxy_nets

  if $systemproxy::ensure == 'present' {
    file { $basedir :
      ensure => $systemproxy::dir_ensure,
      mode   => $systemproxy::params::dir_mode,
    }->
    file { "${basedir}/etc" :
      ensure => $systemproxy::dir_ensure,
      mode   => $systemproxy::params::dir_mode,
    }->
    file { "${basedir}/etc/proxy.pac" :
      ensure  => $systemproxy::ensure,
      content => template('systemproxy/pac.erb'),
    }->
    file { "${basedir}/etc/wpad.dat" :
      ensure => $systemproxy::link_ensure,
      target => 'proxy.pac',
    }
  } else {
    file { "${basedir}/etc/wpad.dat"  : ensure => 'absent', }->
    file { "${basedir}/etc/proxy.pac" : ensure => 'absent', }->
    file { "${basedir}/etc"           : ensure => 'absent', }->
    file { $basedir                   : ensure => 'absent', }
  }
}

