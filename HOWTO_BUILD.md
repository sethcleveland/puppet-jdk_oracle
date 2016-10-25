Requirement
========
- Installation of build environment (bootstrapped by Vagrantfile.)

```shell
vagrant up
vagrant ssh
sudo git clone https://github.com/puppetlabs/puppetlabs-stdlib.git /stdlib
rm -rf /vagrant/pkg
cd /vagrant
puppet module build .
cd /vagrant/pkg
puppet module install schrepfler-jdk_oracle-x.y.z.tar.gz
sudo su
puppet apply --modulepath /home/vagrant/.puppetlabs/etc/code/modules /vagrant/test/manifests/site.pp
```

- Make modifications to module (if bump to java, change default values and bump tests as well.)
- Make modifications to _metadata.json_
- Make modifications to README.md.
- Make modifications to CHANGELOG.md.
- Commit, push, wait for tests available https://travis-ci.org/schrepfler/puppet-jdk_oracle
- Enter VM and build tgz.

Upload module to pupetforge
======
1. Go to https://forge.puppet.com/ and login
2. Open https://forge.puppet.com/upload
3. Upload artifact
