require 'spec_helper'

describe 'jdk_oracle', :type => 'class' do


    context 'When deploying on CentOS' do
        let :facts do {
            :operatingsystem => 'CentOS',
            :osfamily        => 'RedHat',
        }
        end

        context 'with default parameters' do
            it {
                should contain_exec( 'get_jdk_installer').with_creates('/tmp/jdk-8u77-linux-x64.rpm')
                should contain_file('/tmp/jdk-8u77-linux-x64.rpm')
                should contain_exec('install_rpm').with_creates('/usr/java/jdk1.8.0_77')
                should contain_file('/etc/alternatives/java').with({
                    :ensure  => 'link',
                    :target  => '/usr/java/jdk1.8.0_77/bin/java',
                })
            }
        end

    end

    context 'When deploying on unsupported OS' do
        let :facts do {
            :operatingsystem => 'Debian',
            :osfamily        => 'Debian',
        }
        end

        it {
            expect { should raise_error(Puppet::Error) }
        }
    end

end
