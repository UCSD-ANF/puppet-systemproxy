# Set Darwin's proxybypass variables.
define systemproxy::darwin::set (
  $service=$systemproxy::darwin::service,
  $host='Empty',
  $port=0,
  $state='off',
) {
  $networksetup = $systemproxy::darwin::networksetup

  # Set auth to off (assume we have an unathenticated proxy)
  # This also enables the service
  $setargs = $state ? {
    'on'  => "${service} ${host} ${port} off",
    'off' => "${service} Empty",
  }
  $getargs = $state ? {
    'on'  => "${service} | fgrep -v -e '${host}' -e '${port}'",
    'off' => "${service} | grep -v '^Server: \$'",
  }

  exec { "${networksetup} -set${name}proxy ${setargs}":
    onlyif => "${networksetup} -get${name}proxy ${getargs}",
  }
  exec { "${networksetup} -set${name}proxystate ${state}":
    subscribe => Exec["${networksetup} -set${name}proxy ${setargs}"],
  }
}
