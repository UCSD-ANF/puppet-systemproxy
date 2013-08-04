# Feature set for setting up system-wide proxy settings.
# Cribbed from http://wiki.centos.org/TipsAndTricks/YumAndRPM
class systemproxy (
  $host,
  $ensure           = $systemproxy::params::ensure,
  $manage_profile_d = $systemproxy::params::manage_profile_d,
  $no_proxy         = $systemproxy::params::no_proxy,
  $port             = $systemproxy::params::port,
  $proto            = $systemproxy::params::proto,
  $puppet           = $systemproxy::params::puppet,
  $puppet_conf      = $systemproxy::params::puppet_conf,
  $shell_proto      = $systemproxy::params::shell_proto,
) inherits systemproxy::params {

  include stdlib

  validate_bool($manage_profile_d)
  validate_bool($puppet)
  validate_string($no_proxy)

  $proxy = "${proto}://${host}:${port}/"

  # Manage Puppet's own proxy settings
  class { systemproxy::puppet : }

  # Manage Bourne/Bourne-Again/C shell
  # curl, lftp inherit
  class { systemproxy::sh  : }
  class { systemproxy::csh : }

  # Manage wget if we Realize() it in some external class.
  @class { systemproxy::wget : }

  case $::osfamily  {
    'FreeBSD' : { class { systemproxy::bsd : }    }
    'RedHat'  : { class { systemproxy::redhat : } }
    default   : { }
  }
}
