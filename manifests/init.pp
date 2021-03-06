# Feature set for setting up system-wide proxy settings.
# Cribbed from http://wiki.centos.org/TipsAndTricks/YumAndRPM
class systemproxy (
  $host,
  $ensure           = $systemproxy::params::ensure,
  $manage_profile_d = $systemproxy::params::manage_profile_d,
  $alertOn          = $systemproxy::params::alertOn,
  $no_proxy_domains = $systemproxy::params::no_proxy_domains,
  $no_proxy_nets    = $systemproxy::params::no_proxy_nets,
  $port             = $systemproxy::params::port,
  $proto            = $systemproxy::params::proto,
  $puppet           = $systemproxy::params::puppet,
  $puppet_conf      = $systemproxy::params::puppet_conf,
  $shell_proto      = $systemproxy::params::shell_proto,
  $networkservice   = 'Ethernet',
  $gsettings        = $systemproxy::params::gsettings,
  $wget             = $systemproxy::params::wget,
) inherits systemproxy::params {

  include stdlib

  # Check input.
  validate_array($shell_proto)
  validate_bool($manage_profile_d)
  validate_bool($gsettings)
  validate_bool($puppet)
  validate_bool($wget)
  validate_array($no_proxy_domains)
  validate_array($no_proxy_nets)
  validate_re($ensure,'^(abs|pres)ent$')

  # Class variables.
  $proxy      = "${proto}://${host}:${port}/"
  $no_proxy   = flatten([$no_proxy_domains,$no_proxy_nets])
  $dir_ensure = $ensure ? {
    'present' => 'directory',
    default   => $ensure,
  }
  $link_ensure = $ensure ? {
    'present' => 'link',
    default   => $ensure,
  }

  # OS-specific setup.
  case $::osfamily {
    'Darwin'  : { class { systemproxy::darwin  : } }
    'FreeBSD' : { class { systemproxy::bsd     : } }
    'RedHat'  : { class { systemproxy::redhat  : } }
    'Solaris' : { class { systemproxy::solaris : } }
    default   : {                                 }
  }

  # Render Proxy Auto-Config (PAC) files.
  class { systemproxy::pac : }

  # Make sure Puppet has (or hasn't) proxy settings set.
  class { systemproxy::puppet : }

  # Manage Bourne/Bourne-Again/C shell
  # Ensure profile.d dir.
  file { "/etc/profile.d":
    owner  => $systemproxy::params::owner,
    group  => $systemproxy::params::group,
    mode   => $systemproxy::params::dir_mode,
    ensure => 'directory',
  }
  class { systemproxy::sh :
    require => File['/etc/profile.d'],
  }
  class { systemproxy::csh :
    require => File['/etc/profile.d'],
  }

  # Manage GNOME system proxy
  if $::kernel == 'Linux' and $gsettings == true {
    class { systemproxy::gsettings : }
  }

  # Manage wget upon request.
  if $wget {
    class { systemproxy::wget : }
  }
}
