# Copyright 2011 MaestroDev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class sonarqube (
  $version          = '4.5.5',
  $user             = 'sonar',
  $group            = 'sonar',
  $user_system      = true,
  $service          = 'sonar',
  $installroot      = '/usr/local',
  $home             = undef,
  $host             = undef,
  $port             = 9000,
  $portAjp          = -1,
  $download_url     = 'https://sonarsource.bintray.com/Distribution/sonarqube',
  $download_dir     = '/usr/local/src',
  $context_path     = '/',
  $arch             = $sonarqube::params::arch,
  $https            = {},
  $ldap             = {},
  # ldap and pam are mutually exclusive. Setting $ldap will annihilate the setting of $pam
  $pam              = {},
  $crowd            = {},
  $jdbc             = {
    url                               => 'jdbc:h2:tcp://localhost:9092/sonar',
    username                          => 'sonar',
    password                          => 'sonar',
    max_active                        => '50',
    max_idle                          => '5',
    min_idle                          => '2',
    max_wait                          => '5000',
    min_evictable_idle_time_millis    => '600000',
    time_between_eviction_runs_millis => '30000',
  },
  $log_folder       = '/var/local/sonar/logs',
  $updatecenter     = true,
  $http_proxy       = {},
  $profile          = false,
  $web_java_opts    = undef,
  $search_java_opts = undef,
  $search_host      = '127.0.0.1',
  $search_port      = '9001',
  $config           = undef,
  $usepackage       = false,
  $package_name     = 'sonarqube'
) inherits sonarqube::params {
  validate_absolute_path($download_dir)
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }
  File {
    owner => $user,
    group => $group,
  }

  if $home != undef {
    $real_home = $home
  } else {
    $real_home = '/var/local/sonar'
  }

  $installdir = "${installroot}/"
  $extensions_dir = "${real_home}/extensions"
  $plugin_dir = "${extensions_dir}/plugins"


  user { $user:
    ensure     => present,
    home       => $real_home,
    managehome => false,
    system     => $user_system,
  }
  ->
  group { $group:
    ensure => present,
    system => $user_system,
  }

  notify {"Installroot $installroot: ": }



  if $usepackage == true {
    package {$package_name:
      ensure => $version,
    }
  }
  else {
    notfiy {"Removed anti pattern wget, untar  installation": }
  }
  # End crappy install 

  # Sonar configuration files
  notify {"Installdir ${installdir} ": }
  if $config != undef {
    file { "${installdir}/conf/sonar.properties":
      source  => $config,
      require => Exec['untar'],
      notify  => Service['sonarqube'],
      mode    => '0600',
    }
  } else {
    file { "${installdir}/conf/sonar.properties":
      content => template('sonarqube/sonar.properties.erb'),
      notify  => Service['sonarqube'],
      mode    => '0600',
    }
  }


  # The plugins directory. Useful to later reference it from the plugin definition

  file { $plugin_dir:
    ensure => directory,
  }

  service { 'sonarqube':
    ensure     => running,
    name       => $service,
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    #  require    => File["/etc/init.d/${service}"],
  }
}
