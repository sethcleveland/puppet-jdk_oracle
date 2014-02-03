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
                should contain_exec( 'get_jdk_installer').with_creates('/opt/jdk-7u51-linux-x64.rpm')
                should contain_file('/opt/jdk-7u51-linux-x64.rpm')
                should contain_exec('install_rpm').with_creates('/opt/jdk1.7.0')
                should contain_file('/etc/alternatives/java').with({
                    :ensure  => 'link',
                    :target  => '/opt/jdk1.7.0/bin/java',
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
