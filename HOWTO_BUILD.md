Requirement
========
- Installation of build environment (vagrant)

(for this image puppet binary is /opt/puppetlabs/bin/puppet so we'll alias it)
```shell
vagrant box add rhel7-puppet4 https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.1/vagrant-centos-7.1.box
vagrant up
vagrant ssh
sudo yum makecache
sudo yum install -y git nano
alias puppet=/opt/puppetlabs/bin/puppet
cd /vagrant
```

```shell
vagrant box add rhel7-puppet3 https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.0.0/centos-6.6-x86_64.box
vagrant up
vagrant ssh
sudo yum makecache
sudo yum install -y git nano
cd /vagrant
```

(switch VM by editing Vagrantfile and choosing image rhel7-puppet4 or rhel7-puppet3)

- Cleanup any previous packages
```shell
rm -rf ./pkg
```

- Make modifications to module
- Make modifications to _metadata.json_
- Make modifications to README.md
- Commit, push, wait for tests available https://travis-ci.org/schrepfler/puppet-jdk_oracle
- Enter VM and build tgz
```shell
vagrant ssh
cd /vagrant
sudo git clone https://github.com/puppetlabs/puppetlabs-stdlib.git ../stdlib
puppet module build .
cd pkg
puppet module install schrepfler-jdk_oracle-x.y.z.tar.gz
# this should install the module into /home/vagrant/.puppetlabs/etc/code/modules but also /home/vagrant/.puppet/modules/ depending which puppet server you use
sudo puppet apply --modulepath /home/vagrant/.puppetlabs/etc/code/modules /vagrant/test/manifests/site.pp
```

Upload module to pupetforge
======
1. Go to https://forge.puppet.com/ and login
2. Open https://forge.puppet.com/upload
3. Upload artifact