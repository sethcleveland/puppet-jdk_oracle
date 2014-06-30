# Installs the Oracle Java JDK
#
# The puppet cache flag is for faster local vagrant development, to
# locally host the tarball from oracle instead of fetching it each time.
#
class jdk_oracle(
    $version      = hiera('jdk_oracle::version',     '7' ),
    $version7update = hiera('jdk_oracle::version::7::update', '51'),
    $version7build = hiera('jdk_oracle::version::7::build', '-b13'),
    $version8update = hiera('jdk_oracle::version::8::update', '5'),
    $version8build = hiera('jdk_oracle::version::8::build', '-b13'),
    $install_dir  = hiera('jdk_oracle::install_dir', '/opt' ),
    $use_cache    = hiera('jdk_oracle::use_cache',   false ),
    ) {

    # Set default exec path for this module
    Exec { path    => ['/usr/bin', '/usr/sbin', '/bin'] }

    case $version {http://download.oracle.com/otn-pub/java/jdk/8u5-b13/jdk-8u5-linux-i586.rpm
        '7': {
            $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/7u${version7update}${version7build}/jdk-7u${version7update}-linux-x64.rpm"
            $java_home = "${install_dir}/jdk1.7.0"
        }
        '8': {
            $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/8u${version8update}${version8build}/jdk-8u${version8update}-linux-x64.rpm"
            $java_home = "${install_dir}/jdk1.8.0"
        }
        default: {
            fail("Unsupported version: ${version}.  Implement me?")
        }
    }

    $installerFilename = inline_template('<%= File.basename(@javaDownloadURI) %>')

    if ( $use_cache ){
        notify { 'Using local cache for oracle java': }
        file { "${install_dir}/${installerFilename}":
            source  => "puppet:///modules/jdk_oracle/${installerFilename}",
        }
        exec { 'get_jdk_installer':
            cwd     => $install_dir,
            creates => "${install_dir}/jdk_from_cache",
            command => 'touch jdk_from_cache',
            require => File["${install_dir}/jdk-${version}u${version7update}-linux-x64.rpm"],
        }
    } else {
        exec { 'get_jdk_installer':
            cwd     => $install_dir,
            creates => "${install_dir}/${installerFilename}",
            command => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com oraclelicense=accept-securebackup-cookie\" \"${javaDownloadURI}\" -O ${installerFilename}",
            timeout => 600,
            require => Package['wget'],
        }
        file { "${install_dir}/${installerFilename}":
            mode    => '0755',
            require => Exec['install_rpm'],
        }
    }

    # Java 7 comes in a tarball so just extract it.
    if ( $version == '7' ) {
        exec { 'install_rpm':
            cwd     => "${install_dir}/",
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
