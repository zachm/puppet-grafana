# == Class: grafana1
#
# Installs and configures Grafana.
# This is a weirdly namespaced version of an old 1.x fork. Just so you know.
#
# === Parameters
# [*version*]
# Version of grafana that gets installed.
# Defaults to the latest stable version available at the time of module release.
#
# [*install_method*]
# Set to 'archive' to download grafana from the supplied download_url.
# Set to 'package' to use the default package manager for installation.
# Defaults to 'archive'.
#
# [*download_url*]
# URL to download grafana from iff install_method is 'archive'
# Defaults to "http://grafanarel.s3.amazonaws.com/grafana-${version}.tar.gz"
#
# [*install_dir*]
# Installation directory used iff install_method is 'archive'
# Defaults to '/opt'.
#
# [*symlink*]
# Determines if a symlink should be created in the installation directory for
# the extracted archive. Only used if install_method is 'archive'.
# Defaults to 'true'.
#
# [*symlink_name*]
# Sets the name to be used for the symlink. The default is '${install_dir}/grafana'.
# Only used if install_method is 'archive'.
#
# [*grafana_user*]
# The user that will own the installation directory.
# The default is 'root' and there is no logic in place to check that the value
# specified is a valid user on the system.
#
# [*grafana_group*]
# The group that will own the installation directory.
# The default is 'root' and there is no logic in place to check that the value
# specified is a valid group on the system.
#
# [*default_route*]
# The default start dashboard.
# Defaults to '/dashboard/file/default.json'
#
# [*datasources*]
# A hash of hashes that specifies all the connection properties for connecting
# to graphite, elasticsearch, influxdb, and/or opentsb. See params.pp for the
# defaults.
#
# === Examples
#
#  class { '::grafana1':
#    version         => '1.7.0',
#    install_method  => 'package',
#    datasources     => {
#      'graphite' => {
#        'type'  => 'graphite',
#        'url'   => 'http://localhost:80',
#        'default' => 'true'
#      },
#      'elasticsearch' => {
#        'type'    => 'elasticsearch',
#        'url'     => 'http://localhost:9200',
#        'index'   => 'grafana-dash',
#        'grafanaDB' => 'true',
#      },
#    }
#  }
#
class grafana1 (
  $datasources    = $grafana1::params::datasources,
  $default_route  = $grafana1::params::default_route,
  $download_url   = "http://grafanarel.s3.amazonaws.com/grafana-${version}.tar.gz",
  $grafana_group  = $grafana1::params::grafana_group,
  $grafana_user   = $grafana1::params::grafana_user,
  $install_dir    = $grafana1::params::install_dir,
  $install_method = $grafana1::params::install_method,
  $symlink        = $grafana1::params::symlink,
  $symlink_name   = "${install_dir}/grafana",
  $version        = $grafana1::params::version,
) inherits grafana1::params {
  # TODO: make sure at least one is 'default = true' - probably requires use of lambdas
  # TODO: make sure at least one is 'grafanaDB = true' - probably requires use of lambdas

  if empty($datasources) {
    fail('Datasources cannot be empty')
  }

  if $install_method == 'archive' {
    archive { "grafana-${version}":
      ensure   => present,
      checksum => false,
      target   => $install_dir,
      url      => $download_url,
    }

    $require_target = Archive["grafana-${version}"]
    $config_js = "${install_dir}/grafana-${version}/config.js"

    if $symlink {
      file { $symlink_name:
        ensure  => link,
        require => Archive["grafana-${version}"],
        target  => "${install_dir}/grafana-${version}",
      }
    }
  }

  if $install_method == 'package' {
    package { 'grafana':
      ensure => $version,
    }

    $config_js = '/usr/share/grafana/config.js'
    $require_target = Package['grafana']
  }

  file { $config_js:
    ensure  => present,
    content => template('grafana/config.js.erb'),
    group   => $grafana_group,
    owner   => $grafana_user,
    require => $require_target,
  }
}
