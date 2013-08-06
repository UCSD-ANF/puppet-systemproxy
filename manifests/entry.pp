# Manage lines of proxy entries.
define systemproxy::entry (
  $ensure,
  $path,
  $value,
  $match_prefix='^',
  $delim='=',
  $prefix='',
) {
  include stdlib

  file_line { "${name} entry for ${path}":
    ensure => $ensure,
    path   => $path,
    line   => "${prefix}${name}${delim}${value}",
    match  => "${match_prefix}${prefix}${name}${delim}",
  }
}
