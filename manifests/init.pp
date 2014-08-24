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
    ) {

    # Set default exec path for this module
    Exec { path    => ['/usr/bin', '/usr/sbin', '/bin'] }

    case $version {
        '7': {
            $javaUpdate = hiera('jdk_oracle::version::7::update', '67')
            $javaBuild = hiera('jdk_oracle::version::7::build', '01')
        }
        '8': {
            $javaUpdate = hiera('jdk_oracle::version::8::update', '20')
            $javaBuild = hiera('jdk_oracle::version::8::build', '26')
        }
        default: {
            fail("Unsupported version: ${version}.  Implement me?")
        }
    }
    
    $java_home = "${install_dir}/jdk1.$version.0_$javaUpdate"
    $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/${version}u${javaUpdate}-b${javaBuild}/jdk-${version}u${javaUpdate}-linux-${arch}.rpm"

    $installerFilename = inline_template('<%= File.basename(@javaDownloadURI) %>')

    if ( $use_cache ){
        notify { 'Using local cache for oracle java': }
        file { "${tmp_dir}/${installerFilename}":
            source  => "puppet:///modules/jdk_oracle/${installerFilename}",
        }
        exec { 'get_jdk_installer':
            cwd     => $tmp_dir,
            creates => "${tmp_dir}/jdk_from_cache",
            command => 'touch jdk_from_cache',
            require => File["${tmp_dir}/jdk-${version}u${javaUpdate}-linux-x64.rpm"],
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
        package { 'wget':
          ensure => present,
        }
    }

    # Java 7 comes in a tarball so just extract it.
    if ( $version == '7' ) {
        exec { 'install_rpm':
            cwd     => "${tmp_dir}/",
            command => "rpm -i ${installerFilename}",
            creates => $java_home,
            require => Exec['get_jdk_installer'],
        }
    }

    # Set links depending on osfamily or operating system fact
    case $::osfamily {
        RedHat, Linux: {
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
        }
        Debian:    { fail('TODO: Implement me!') }
        Suse:      { fail('TODO: Implement me!') }
        Solaris:   { fail('TODO: Implement me!') }
        Gentoo:    { fail('TODO: Implement me!') }
        Archlinux: { fail('TODO: Implement me!') }
        Mandrake:  { fail('TODO: Implement me!') }
        default:     { fail('Unsupported OS') }
    }

}
