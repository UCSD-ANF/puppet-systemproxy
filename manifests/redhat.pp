# set RedHat-specific elements up to use a proxy.
# This class should only be called from init.pp
class systemproxy::redhat {

  # Set rpm to use a proxy.
  # RPM config file should always have a line that matches our regex.
  # Further, we want the variables set at the point in the config file
  # where their listed.  As such, set conditionally, then make the
  # conditional contents present, no matter what $ensure says.
  $ftpport = $systemproxy::ensure ? {
    'present' => "%_ftpport ${systemproxy::port}",
    default   => '#%_ftpport',
  }
  $ftpproxy = $systemproxy::ensure ? {
    'present' => "%_ftpproxy ${systemproxy::host}",
    default   => '#%_ftpproxy',
  }
  $httpport = $systemproxy::ensure ? {
    'present' => "%_httpport ${systemproxy::port}",
    default   => '#%_httpport',
  }
  $httpproxy = $systemproxy::ensure ? {
    'present' => "%_httpproxy ${systemproxy::host}",
    default   => '#%_httpproxy',
  }

  file_line { 'RPM %_ftpproxy':
    ensure => 'present',
    path   => '/usr/lib/rpm/macros',
    line   => $ftpproxy,
    match  => '%_ftpproxy',
  }->
  file_line { 'RPM %_ftpport':
    ensure => 'present',
    path   => '/usr/lib/rpm/macros',
    line   => $ftpport,
    match  => '%_ftpport',
  }->
  file_line { 'RPM %_httpproxy':
    ensure => 'present',
    path   => '/usr/lib/rpm/macros',
    line   => $httpproxy,
    match  => '%_httpproxy',
  }->
  file_line { 'RPM %_httpport':
    ensure => 'present',
    path   => '/usr/lib/rpm/macros',
    line   => $httpport,
    match  => '%_httpport',
  }

  file_line { 'YUM global proxy':
    ensure => $systemproxy::ensure,
    path   => '/etc/yum.conf',
    line   => "proxy=${systemproxy::proxy}",
    match  => '^proxy',
  }
}
