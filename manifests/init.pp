# == Class: jdk_oracle
#
# Installs the Oracle Java JDK RPM, from the Oracle servers
#
# === Parameters
#
# [*version*]
#   String.  Java Version to install
#   Defaults to <tt>8</tt>.
#
# [* java_install_dir *]
#   String.  Java Installation Directory
#   Defaults to <tt>/opt</tt>.
#
# [* use_cache *]
#   Boolean.  Optionally host the installer file locally instead of fetching it each time (for faster dev & test)
#   The puppet cache flag is for faster local vagrant development, to
#   locally host the tarball from oracle instead of fetching it each time.
#   Defaults to <tt>false</tt>.
#
# [* platform *]
#   String.  The platform to use
#   Defaults to <tt>x64</tt>.
#
# [* jce *]
#   Boolean.  Optionally install Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files
#   Defaults to <tt>false</tt>.
#
# [* default_java *]
#   Boolean.  If the installed java version is linked as the default java, javac etc...
#   Defaults to <tt>true</tt>.
#
# [* ensure *]
#   String.  Specifies if jdk should be installed or absent
#   Defaults to <tt>installed</tt>.
#
class jdk_oracle (
  $version      = 8,
  $arch         = hiera('jdk_oracle::arch', 'x64'),
  $install_dir  = hiera('jdk_oracle::install_dir', '/usr/java'),
  $tmp_dir      = hiera('jdk_oracle::tmp_dir', '/tmp'),
  $use_cache    = hiera('jdk_oracle::use_cache', false),
  $cache_source = 'puppet:///modules/jdk_oracle/',
  $jce          = hiera('jdk_oracle::jce', false),
  $default_java = hiera('jdk_oracle::default_java', true)) {
  validate_integer($version)

  # Set default exec path for this module
  Exec {
    path => ['/usr/bin', '/usr/sbin', '/bin'] }

  case $version {
    7       : {
      $java_update = hiera('jdk_oracle::version::7::update', 80)
      $java_build = hiera('jdk_oracle::version::7::build', 15)
    }
    8       : {
      $java_update = hiera('jdk_oracle::version::8::update', 111)
      $java_build = hiera('jdk_oracle::version::8::build', 14)
    }
    default : {
      fail("Unsupported version: ${version}. Supported versions are 7 and 8")
    }
  }

  $java_home = "${install_dir}/jdk1.${version}.0_${java_update}"
  $java_download_uri = "http://download.oracle.com/otn-pub/java/jdk/${version}u${java_update}-b${java_build}/jdk-${version}u${java_update}-linux-${arch}.rpm"
  $jce_download_uri = 'http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip'
  $installer_filename = inline_template('<%= File.basename(@java_download_uri) %>')
  $wget_header = 'wget -c --no-cookies --no-check-certificate --header'
  $cookie = "\"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com; oraclelicense=accept-securebackup-cookie\""

  if ($use_cache) {
    notify { 'Using local cache for oracle java': }

    file { "${tmp_dir}/${installer_filename}":
      source  => "${cache_source}${installer_filename}",
      require => File[$tmp_dir],
    }

    exec { 'get_jdk_installer':
      cwd     => $tmp_dir,
      creates => "${tmp_dir}/jdk_from_cache",
      command => 'touch jdk_from_cache',
      require => File["${tmp_dir}/jdk-${version}u${java_update}-linux-x64.rpm"],
    }

    if !defined(File[$install_dir]) {
      file { $tmp_dir: ensure => 'directory', }
    }
  } else {
    exec { 'remove_empty_jdk_installer':
      cwd     => $tmp_dir,
      command => "rm -f ${installer_filename}",
      unless  => "test -s ${installer_filename}",
    } ->
    exec { 'get_jdk_installer':
      cwd     => $tmp_dir,
      creates => "${tmp_dir}/${installer_filename}",
      command => "${wget_header} ${cookie} \"${java_download_uri}\" -O ${installer_filename}",
      timeout => 600,
      require => Package['wget'],
    }

    file { "${tmp_dir}/${installer_filename}":
      mode    => '0755',
      require => Exec['install_rpm'],
    }

    if !defined(Package['wget']) {
      package { 'wget': ensure => present, }
    }

    if !defined(Package['unzip']) {
      package { 'unzip': ensure => present, }
    }

  }

  # Set links depending on osfamily or operating system fact
  case $::osfamily {
    'RedHat', 'Linux' : {
      if ($default_java) {
        file { '/etc/alternatives/java':
          ensure  => link,
          target  => "${java_home}/bin/java",
          require => Exec['install_rpm'],
        }

        file { '/etc/alternatives/javac':
          ensure  => link,
          target  => "${java_home}/bin/javac",
          require => Exec['install_rpm'],
        }

        file { '/etc/alternatives/jar':
          ensure  => link,
          target  => "${java_home}/bin/jar",
          require => Exec['install_rpm'],
        }

        file { '/usr/sbin/java':
          ensure  => link,
          target  => '/etc/alternatives/java',
          require => File['/etc/alternatives/java'],
        }

        file { '/usr/sbin/javac':
          ensure  => link,
          target  => '/etc/alternatives/javac',
          require => File['/etc/alternatives/javac'],
        }

        file { '/usr/sbin/jar':
          ensure  => link,
          target  => '/etc/alternatives/jar',
          require => File['/etc/alternatives/jar'],
        }

        file { '/etc/profile.d/java.sh':
          ensure  => present,
          content => "export JAVA_HOME=${java_home}; PATH=\${PATH}:${java_home}/bin",
          require => Exec['install_rpm'],
        }
      }

      file { '/opt/java_home':
        ensure  => link,
        target  => $java_home,
        require => Exec['install_rpm'],
      }

      exec { 'install_rpm':
        cwd     => "${tmp_dir}/",
        command => "rpm -i ${installer_filename}",
        creates => $java_home,
        require => Exec['get_jdk_installer'],
      }
    }
    'Debian'          : {
      fail('TODO: Implement me!')
    }
    'Suse'            : {
      fail('TODO: Implement me!')
    }
    'Solaris'         : {
      fail('TODO: Implement me!')
    }
    'Gentoo'          : {
      fail('TODO: Implement me!')
    }
    'Archlinux'       : {
      fail('TODO: Implement me!')
    }
    'Mandrake'        : {
      fail('TODO: Implement me!')
    }
    default           : {
      fail("Unsupported OS: ${::osfamily}.  Implement me?")
    }
  }

  if ($jce and $version == '8') {
    $jce_filename = inline_template('<%= File.basename(@jce_download_uri) %>')
    $jce_dir = 'UnlimitedJCEPolicyJDK8'

    if ($use_cache) {
      file { "${tmp_dir}/${jce_filename}":
        source  => "${cache_source}${jce_filename}",
        require => File[$install_dir],
      } ->
      exec { 'get_jce_package':
        cwd     => $install_dir,
        creates => "${install_dir}/jce_from_cache",
        command => 'touch jce_from_cache',
      }
    } else {
      exec { 'get_jce_package':
        cwd     => $install_dir,
        creates => "${install_dir}/${jce_filename}",
        command => "${wget_header} ${cookie} \"${jce_download_uri}\" -O ${jce_filename}",
        timeout => 600,
        require => Package['wget'],
      }

      file { "${install_dir}/${jce_filename}":
        mode    => '0755',
        require => Exec['get_jce_package'],
      }

    }

    exec { 'extract_jce':
      cwd     => "${install_dir}/",
      command => "unzip ${jce_filename}",
      creates => "${install_dir}/${jce_dir}",
      require => [Exec['get_jce_package'], Package['unzip']],
    }

    file { "${java_home}/jre/lib/security/README.txt":
      ensure  => 'present',
      source  => "${install_dir}/${jce_dir}/README.txt",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Exec['extract_jce'],
    }

    file { "${java_home}/jre/lib/security/local_policy.jar":
      ensure  => 'present',
      source  => "${install_dir}/${jce_dir}/local_policy.jar",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Exec['extract_jce'],
    }

    file { "${java_home}/jre/lib/security/US_export_policy.jar":
      ensure  => 'present',
      source  => "${install_dir}/${jce_dir}/US_export_policy.jar",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Exec['extract_jce'],
    }
  }
}
