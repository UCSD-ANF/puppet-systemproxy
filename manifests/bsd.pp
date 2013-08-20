# Set (Free?)BSD-specific elements up to use a proxy.
# This class should only be called from init.pp
class systemproxy::bsd {

  include stdlib

  # Per http://puppetcookbook.com/posts/only-create-file-if-absent.html,
  # ensure file exists so that file_line doesn't complain.
  # This will also always ensure permissions/custody.
  file { '/etc/make.conf':
    ensure  => 'present',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    replace => 'no',
  }

  $protos    = prefix($systemproxy::shell_proto, 'export ')
  $no_protos = prefix([ 'no_proxy','NO_PROXY' ], 'export ')

  # Use defined type to make/edit make.conf
  systemproxy::entry { $protos :
    ensure  => $systemproxy::ensure,
    path    => '/etc/make.conf',
    value   => $systemproxy::proxy,
    require => File['/etc/make.conf'],
  }
  if $systemproxy::no_proxy != false {
    systemproxy::entry { $no_protos :
      ensure  => $systemproxy::ensure,
      path    => '/etc/make.conf',
      value   => $systemproxy::no_proxy,
      require => File['/etc/make.conf'],
    }
  }
}
