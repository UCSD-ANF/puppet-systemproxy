# Manage proxy settings for Bourne, Bourne-Again and C shell.
# This class should only be called from init.pp
class systemproxy::csh {
  include stdlib

  # Ensure profile.d dir.
  file { "/etc/profile.d for ${name}":
    ensure => 'directory',
    path   => '/etc/profile.d',
  }

  # Hack on the default files if we need/want to.
  if $systemproxy::manage_profile_d == true {
    # Add basic profile.d support to C shell.
    file_line { 'enable /etc/profile.d for /etc/csh.cshrc':
      ensure  => $systemproxy::ensure,
      path    => '/etc/csh.cshrc',
      line    => 'source /etc/profile.d/*.csh',
      match   => '^source /etc/profile\.d/\*.csh',
    }
  }

  # Set up C shell proxy.
  $delim        = ' '
  $protos       = prefix($systemproxy::shell_proto, 'setenv ')
  $no_protos    = prefix(['no_proxy','NO_PROXY'], 'setenv ')
  $no_proxy_str = join($systemproxy::no_proxy,',')
  file { '/etc/profile.d/proxy.csh':
    ensure  => $systemproxy::ensure,
    content => template('systemproxy/proxy.erb'),
    require => File["/etc/profile.d for ${name}"],
  }
}
