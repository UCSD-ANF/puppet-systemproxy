# NOT YET USED.
# Set GNOME-specific elements up to use a proxy via
# this module's rendered PAC file.
# This class should only be called from init.pp
#
# Handy commands.
# /usr/bin/gsettings list-children org.gnome.system.proxy
# /usr/bin/gsettings list-keys org.gnome.system.proxy
class systemproxy::gsettings {

  include stdlib
  include systemproxy::params

  $gsettings = '/usr/bin/gsettings'
  $schema    = 'org.gnome.system.proxy'
  $uri       = $systemproxy::params::pac_uri

  $getargs = $systemproxy::ensure ? {
    'present' => "get ${schema} autoconfig-url | fgrep '${uri}'",
    'absent'  => "get ${schema} autoconfig-url | fgrep \"''\"",
  }
  $setargs = $systemproxy::ensure ? {
    'present' => "set ${schema} autoconfig-url ${uri}",
    'absent'  => "set ${schema} autoconfig-url ''",
  }
  $setmode = $systemproxy::ensure ? {
    'present' => 'manual',
    'absent'  => 'none',
  }

  # Set autoconfig-url if not our URL.
  exec { "${gsettings} ${setargs}":
    unless  => "${gsettings} ${getargs}",
    require => Class['systemproxy::pac'],
  }

  # Change mode if changing autoconfig-url.
  exec { "${gsettings} set ${schema} mode ${setmode}":
    subscribe => Exec["${gsettings} ${setargs}"],
  }
}
