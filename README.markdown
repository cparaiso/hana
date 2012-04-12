# [Hana](http://en.wikipedia.org/wiki/Hana_Highway)

## Description
Hana is a command line toolset made for developers who switch to many different [uPortal](http://www.jasig.org/uportal) or [CAS](http://www.jasig.org/cas) projects a day.

## Installation
### Installing the gem
    gem install hana
    hana admin install
### Cloning from git, build/install gem from source
    git clone git@github.com:cparaiso/hana.git
    cd hana
    gem build hana.gemspec
    gem install hana-$VERSION.gem
    hana admin install # creates a config file (config.rb) and a storage file (projects.yml) that keeps track of your projects.  These files can be located in the $HOME/.hana directory.

## Usage
Running the command below from the terminal lists the commands available in Hana:

    hana

## TODO
CAS tasks :(