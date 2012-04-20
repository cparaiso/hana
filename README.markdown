# Hana
## Description
My personal toolset built using the [Thor](https://github.com/wycats/thor) gem to manage tasks and project switching for uPortal and CAS.

This toolset is largely opinionated and assumes a lot.  Requires:

    ~/dev/src    # directory where all source files from projects will be stored
    ~/dev/deploy    # directory where all tomcat instances will be stored

## Installation
### Installing the gem
    gem install hana    # will not work until version 1.0.0
    hana admin install
### Cloning from git, build/install gem from source
    git clone git@github.com:cparaiso/hana.git
    cd hana
    rake install    # builds/installs gem.
    hana admin install    # creates a config file (config.rb) and a storage file (projects.yml) that keeps track of your projects.  These files can be located in the $HOME/.hana directory.

## Usage
    hana    # lists commands available
    hana <subcommand>    # lists available subcommands

## Workflow
		~ $ hana project create unicorn -t uportal -v 4.0.3
		      tomcat  Found cached Tomcat file.  Using it.
		     uportal  Found cached file.  Using it.
		      tomcat  Extracting tomcat.
		      tomcat  Configuring Tomcat.
		      tomcat  Configuring catalina.properties.
		      tomcat  Configuring server.xml.
		     uportal  Setting up uPortal.
		     uportal  Extracted to folder: /Users/cparaiso/dev/src/unicorn-src
		     uportal  Configuring build.properties.
		    finished  unicorn created.  Don't forget to switch to the project.
		~ $ hana project switch unicorn
		    switched  Project switched to: unicorn
		~ $ hana db start
		     uportal  Starting database.
		Buildfile: /Users/cparaiso/dev/src/unicorn-src/build.xml
		    [mkdir] Created dir: /var/folders/8v/1k2gkj412q1_8084x6lvtbqr0000gn/T/jasig

		hsql:

		install-parent-pom:
		[artifact:install] [INFO] Installing /Users/cparaiso/dev/src/unicorn-src/pom.xml to /Users/cparaiso/.m2/repository/org/jasig/portal/uportal-parent/4.0.3/uportal-parent-4.0.3.pom
		    [touch] Creating /var/folders/8v/1k2gkj412q1_8084x6lvtbqr0000gn/T/jasig/uportal-parent.pom-88314651-marker
		     [echo] Starting HSQL on 8887
		     [echo] Using: file:/Users/cparaiso/dev/src/unicorn-src/data/uPortal

		BUILD SUCCESSFUL
		Total time: 3 seconds
		     uportal  Database started.
		~ $ hana uportal init
		... initportal output
		~ $ hana tomcat start
		... logs/catalina.out output
## TODO
more CAS tasks :(