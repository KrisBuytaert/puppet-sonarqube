# Configuration of SonarQube Runner
class sonarqube::runner::config (
  $package_name,
  $version,
  $installroot,
  $sonarqube_server = 'http://localhost:9000',
  $jdbc             = {
    url      => 'jdbc:h2:tcp://localhost:9092/sonar',
    username => 'sonar',
    password => 'sonar',
  },
) {
  # Sonar Runner configuration file
  # Given that there either is a  symlink the to dir in the install.pp or the 
  # package deploysin the right directory -$version is redundant
  file { "${installroot}/${package_name}/conf/sonar-runner.properties":
    content => template('sonarqube/sonar-runner.properties.erb'),
    require => Class[''],
  }
}
