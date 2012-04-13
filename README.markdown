# Hana

## Description
My personal toolset built using the [Thor](https://github.com/wycats/thor) gem to manage tasks and project switching for uPortal and CAS.

This toolset is largely opinionated and assumes a lot.  Requires:

    ~/dev/src						# directory where all source files from projects will be stored
    ~/dev/deploy				# directory where all tomcat instances will be stored

## Installation
### Installing the gem
    gem install hana 		# will not work until version 1.0.0
    hana admin install
### Cloning from git, build/install gem from source
    git clone git@github.com:cparaiso/hana.git
    cd hana
    rake install				# builds/installs gem.
    hana admin install	# creates a config file (config.rb) and a storage file (projects.yml) that keeps track of your projects.  These files can be located in the $HOME/.hana directory.

## Usage
Running the command below from the terminal lists the commands available in Hana:

    hana								# lists commands available
    hana <subcommand>		# lists available subcommands

## TODO
more CAS tasks :(