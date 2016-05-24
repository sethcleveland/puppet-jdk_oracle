# Installs the Oracle Java JDK
#
# The puppet cache flag is for faster local vagrant development, to
# locally host the tarball from oracle instead of fetching it each time.
#
class jdk_oracle(
    $version      = hiera('jdk_oracle::version', '8' ),
    $arch      = hiera('jdk_oracle::arch', 'x64' ),
    $install_dir  = hiera('jdk_oracle::install_dir', '/usr/java' ),
    $tmp_dir  = hiera('jdk_oracle::tmp_dir', '/tmp' ),
    $use_cache    = hiera('jdk_oracle::use_cache',   false ),
    $jce            = hiera('jdk_oracle::jce',            false ),
    ) {

    # Set default exec path for this module
    Exec { path    => ['/usr/bin', '/usr/sbin', '/bin'] }

    case $version {
        '7': {
            $javaUpdate = hiera('jdk_oracle::version::7::update', '80')
            $javaBuild = hiera('jdk_oracle::version::7::build', '15')
        }
        '8': {
            $javaUpdate = hiera('jdk_oracle::version::8::update', '91')
            $javaBuild = hiera('jdk_oracle::version::8::build', '14')
        }
        default: {
            fail("Unsupported version: ${version}.  Implement me?")
        }
    }
    
    $java_home = "${install_dir}/jdk1.${version}.0_${javaUpdate}"
    $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/${version}u${javaUpdate}-b${javaBuild}/jdk-${version}u${javaUpdate}-linux-${arch}.rpm"
    $jceDownloadURI = "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"

    $installerFilename = inline_template('<%= File.basename(@javaDownloadURI) %>')

    if ( $use_cache ){
        notify { 'Using local cache for oracle java': }
        file { "${tmp_dir}/${installerFilename}":
            source  => "puppet:///modules/jdk_oracle/${installerFilename}",
            require => File[$tmp_dir],
        }

        exec { 'get_jdk_installer':
            cwd     => $tmp_dir,
            creates => "${tmp_dir}/jdk_from_cache",
            command => 'touch jdk_from_cache',
            require => File["${tmp_dir}/jdk-${version}u${javaUpdate}-linux-x64.rpm"],
        }

        if ! defined(File[$install_dir]) {
            file { $tmp_dir:
                ensure => 'directory',
            }
        }

    } else {
        exec { 'get_jdk_installer':
            cwd     => $tmp_dir,
            creates => "${tmp_dir}/${installerFilename}",
            command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com; oraclelicense=accept-securebackup-cookie\" \"${javaDownloadURI}\" -O ${installerFilename}",
            timeout => 600,
            require => Package['wget'],
        }
        file { "${tmp_dir}/${installerFilename}":
            mode    => '0755',
            require => Exec['install_rpm'],
        }

        if ! defined(Package['wget']) {
            package { 'wget':
              ensure => present,
            }
        }

        if ! defined(Package['unzip']) {
            package { 'unzip':
              ensure =>  present,
            }
        }

    }

    # Set links depending on osfamily or operating system fact
    case $::osfamily {
        'RedHat', 'Linux': {
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
            file { '/opt/java_home':
                ensure  => link,
                target  => $java_home,
                require => Exec['install_rpm'],
            }
            exec { 'install_rpm':
            cwd     => "${tmp_dir}/",
            command => "rpm -i ${installerFilename}",
            creates => $java_home,
            require => Exec['get_jdk_installer'],
            }
        }
        'Debian':    { fail('TODO: Implement me!') }
        'Suse':      { fail('TODO: Implement me!') }
        'Solaris':   { fail('TODO: Implement me!') }
        'Gentoo':    { fail('TODO: Implement me!') }
        'Archlinux': { fail('TODO: Implement me!') }
        'Mandrake':  { fail('TODO: Implement me!') }
        default:     { fail("Unsupported OS: ${::osfamily}.  Implement me?") }
    }

    if ( $jce and $version == '8' ) {

      $jceFilename = inline_template('<%= File.basename(@jceDownloadURI) %>')
      $jce_dir = "UnlimitedJCEPolicyJDK8"

      if ( $use_cache ) {
        file { "${install_dir}/${jceFilename}":
          source  => "${cache_source}${jceFilename}",
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
          creates => "${install_dir}/${jceFilename}",
          command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" --header \"Cookie: oraclelicense=accept-securebackup-cookie\" \"${jceDownloadURI}\" -O ${jceFilename}",
          timeout => 600,
          require => Package['wget'],
        }

        file { "${install_dir}/${jceFilename}":
          mode    => '0755',
          require => Exec['get_jce_package'],
        }

      }

      exec { 'extract_jce':
        cwd     => "${install_dir}/",
        command => "unzip ${jceFilename}",
        creates => "${install_dir}/${jce_dir}",
        require => [ Exec['get_jce_package'], Package['unzip'] ],
      }

      file { "${java_home}/jre/lib/security/README.txt":
        ensure  => 'present',
        source  => "${install_dir}/${jce_dir}/README.txt",
        mode    => 0644,
        owner   => 'root',
        group   => 'root',
        require => Exec['extract_jce'],
      }

      file { "${java_home}/jre/lib/security/local_policy.jar":
        ensure  => 'present',
        source  => "${install_dir}/${jce_dir}/local_policy.jar",
        mode    => 0644,
        owner   => 'root',
        group   => 'root',
        require => Exec['extract_jce'],
      }

      file { "${java_home}/jre/lib/security/US_export_policy.jar":
        ensure  => 'present',
        source  => "${install_dir}/${jce_dir}/US_export_policy.jar",
        mode    => 0644,
        owner   => 'root',
        group   => 'root',
        require => Exec['extract_jce'],
      }

    }

}