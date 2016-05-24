Requirement
========
- Installation of build environment (vagrant)

```shell
vagrant box add rhel7 https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.1/vagrant-centos-7.1.box
vagrant init rhel7
vagrant up
```

- Cleanup any previous packages
```shell
rm -rf ./pkg
```

- Make modifications to module
- Make modifications to _metadata.json_
- Commit, push, wait for tests available [https://travis-ci.org/schrepfler/puppet-jdk_oracle]
- Enter VM and build tgz
```shell

```