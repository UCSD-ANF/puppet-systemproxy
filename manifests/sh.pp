# Manage proxy settings for Bourne, Bourne-Again and C shell.
# This class should only be called from init.pp
class systemproxy::sh {
  include stdlib

  # Hack on the default files if we need/want to.
  if $systemproxy::manage_profile_d == true {
    # Add basic profile.d support to Bourne/Bourne-Again shell.
    file_line { 'enable /etc/profile.d for /etc/bashrc':
      ensure  => $systemproxy::ensure,
      path    => '/etc/bashrc',
      line    => 'source /etc/profile.d/*.sh',
      match   => '^source /etc/profile\.d/\*.sh',
    }
    file_line { 'enable /etc/profile.d for /etc/profile':
      ensure  => $systemproxy::ensure,
      path    => '/etc/profile',
      line    => 'source /etc/profile.d/*.sh',
      match   => '^source /etc/profile\.d/\*.sh',
    }
  }

  # Set up Bourne/Bourne-Again shell proxy.
  $delim        = '='
  $protos       = prefix($systemproxy::shell_proto, 'export ')
  $no_protos    = prefix(['no_proxy','NO_PROXY'], 'export ')
  $no_proxy_str = join($systemproxy::no_proxy,',')
  file { '/etc/profile.d/proxy.sh':
    ensure  => $systemproxy::ensure,
    content => template('systemproxy/proxy.erb'),
    require => File["/etc/profile.d for ${name}"],
  }
}
