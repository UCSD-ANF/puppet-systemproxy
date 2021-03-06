# Set wget to use a proxy
# This class should only be called from init.pp
#
# Expects wget files to be installed elsewhere.
class systemproxy::wget {

  include systemproxy::params

  file_line { 'use_proxy for wget':
    ensure  => $systemproxy::ensure,
    path    => $systemproxy::params::wgetrc,
    line    => 'use_proxy = on',
    match   => '^use_proxy',
  }->
  file_line { 'ftp_proxy for wget':
    ensure => $systemproxy::ensure,
    path   => $systemproxy::params::wgetrc,
    line   => "ftp_proxy = ${systemproxy::proxy}",
    match  => '^ftp_proxy',
  }->
  file_line { 'http_proxy for wget':
    ensure => $systemproxy::ensure,
    path   => $systemproxy::params::wgetrc,
    line   => "http_proxy = ${systemproxy::proxy}",
    match  => '^http_proxy',
  }->
  file_line { 'https_proxy for wget':
    ensure => $systemproxy::ensure,
    path   => $systemproxy::params::wgetrc,
    line   => "https_proxy = ${systemproxy::proxy}",
    match  => '^https_proxy',
  }
}
