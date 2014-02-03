puppet-jdk_oracle
=================

Puppet module to install a JDK from the RPM binary distribution from oracle using wget.
Based on the https://github.com/tylerwalts/puppet-jdk_oracle this module removed support for JDK6 and the tgz installer.

Source: http://www.oracle.com/technetwork/java/javase/downloads/index.html

_Note:  By using this module you will automatically accept the Oracle agreement to download Java._

This module will work on Redhat family of OSs, and will use wget with a cookie to automatically grab the RPM installer from Oracle.

This approach was inspired by: http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux


Currently Supported:
* RedHat Family (RedHat, Fedora, CentOS)
* Java 7

Installation:
=============

A) Traditional:
* Copy this project into your puppet modules path and rename to "jdk_oracle"

B) Puppet Librarian:
* Put this in your Puppetfile:
```
    mod "jdk_oracle",
        :git => "git://github.com/schrepfler/puppet-jdk_oracle.git"
```


Usage:
======

A)  Traditional:
```
    include jdk_oracle
```
or
```
    class { 'jdk_oracle': }
```


B) Hiera:
config.json:
```
    {
        classes":[
          "jdk_oracle"
        ]
    }
```
OR
config.yaml:
```
---
  classes: 
    - "jdk_oracle"
  jdk_oracle::version: "6"
```

site.pp:
```
    hiera_include("classes", [])
```


Parameters:
===========

* version
    * Java Version to install
* java_install_dir
    * Java Installation Directory
* version7update
	* Java 7  Update version
* version7build
	* Java 7 Build version
* use_cache
    * Optionally host the installer file locally instead of fetching it each time, for faster dev & test


TODO:
=====

* Automate installation of security policies
* Refactor tests to support some use cases of the tgz module
* Add support for 32-bit JDK
* Add build status icons
