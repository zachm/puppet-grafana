# == Class: grafana1
#
# Default parameters
#
class grafana1::params {
  $datasources    = {
    'elasticsearch' => {
      'grafanaDB' => 'true', # lint:ignore:quoted_booleans
      'index'     => 'grafana-dash',
      'type'      => 'elasticsearch',
      'url'       => 'http://localhost:9200',
    },
    'graphite' => {
      'default' => 'true', # lint:ignore:quoted_booleans
      'type'    => 'graphite',
      'url'     => 'http://localhost:80',
    },
  }

  $default_route      = '/dashboard/file/default.json'
  $grafana_group      = 'root'
  $grafana_user       = 'root'
  $install_dir        = '/opt'
  $install_method     = 'archive'
  $max_search_results = 20
  $symlink            = true
  $version            = '1.8.1'
}
