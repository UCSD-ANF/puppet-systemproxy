# Set Solaris-specific elements up to use a proxy per
# http://www.opencsw.org/manual/for-administrators/getting-started.html
# This class should only be called from init.pp
class systemproxy::solaris {

  include stdlib

  $ftp = "-e ftp_proxy=${systemproxy::proxy}"
  $http = "-e http_proxy=${systemproxy::proxy}"
  $https = "-e https_proxy=${systemproxy::proxy}"

  if $systemproxy::no_proxy {
    $no_proxy_str = join($systemproxy::no_proxy,',')
    $no_proxy = "-e no_proxy=\"${no_proxy_str}\""
  } else {
    $no_proxy = ''
  }

  $line = $systemproxy::ensure ? {
    'present' => "wgetopts=-U pkgutil ${ftp} ${http} ${https} ${no_proxy}",
    default   => '#wgetopts=-U pkgutil',
  }
  file_line { 'wgetopts for pkgutil':
    ensure  => 'present',
    path    => '/etc/opt/csw/pkgutil.conf',
    line    => $line,
    match   => 'wgetopts=',
  }
}
