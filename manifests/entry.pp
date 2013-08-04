# Manage lines of proxy entries.
define systemproxy::entry (
  $ensure,
  $path,
  $value,
  $match_prefix='^',
  $delim='=',
  $prefix='',
  $owner='root',
  $group = $::kernel ? {
    /(Darwin|FreeBSD)/ => 'wheel',
    'SunOS'            => 'bin',
    default            => 'root',
  },
  $mode='0644',
) {
  include stdlib

  # Per http://puppetcookbook.com/posts/only-create-file-if-absent.html,
  # ensure file exists so that file_line doesn't complain.
  # Ensure proper permissions/custody.
  file { "${name} entry for ${path}" :
    ensure  => 'present',
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    path    => $path,
    replace => 'no',
  }

  file_line { "${name} entry for ${path}":
    ensure  => $ensure,
    path    => $path,
    line    => "${prefix}${name}${delim}${value}",
    match   => "${match_prefix}${prefix}${name}${delim}",
    require => File["${name} entry for ${path}"],
  }
}
