Requirement
========
- Installation of build environment (vagrant)

```shell
vagrant box add rhel7 https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.1/vagrant-centos-7.1.box
vagrant init rhel7
vagrant up
vagrant ssh
sudo yum update
sudo yum makecache
sudo yum install git nano
```

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
/opt/puppetlabs/bin/puppet module build .
```

Upload module to pupetforge
======
1. Go to https://forge.puppet.com/ and login
2. Open https://forge.puppet.com/upload
3. Upload artifact