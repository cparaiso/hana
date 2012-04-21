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
	~ $ hana project create unicorn -t uportal -v 4.0.3    # create project
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
	~ $ hana project switch unicorn    # switch to project
	    switched  Project switched to: unicorn
	~ $ hana db start    # start hsql
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
	~ $ hana uportal init # build
	... initportal output
	~ $ hana tomcat start # start tomcat
	... logs/catalina.out output
## TODO
more CAS tasks :(


----


---
layout: post
title: "Testing elements"
date: 2012-04-15 15:02
comments: true
sharing: true
categories: [Testing, Personal]
---

## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6

## Paragraph
Porem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse nec orci sit amet arcu interdum malesuada. Quisque ac metus felis, sed commodo risus. Mauris sit amet adipiscing mauris. Mauris bibendum augue ut libero sodales sodales. Donec faucibus imperdiet justo, vel malesuada lorem imperdiet a. Phasellus at orci elit, eget tincidunt sapien. In ullamcorper aliquam lorem, vitae blandit massa consequat ut.

- li 1
- li 2
- li 3
- li 4

Porem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse nec orci sit amet arcu interdum malesuada. Quisque ac metus felis, sed commodo risus. Mauris sit amet adipiscing mauris. Mauris bibendum augue ut libero sodales sodales. Donec faucibus imperdiet justo, vel malesuada lorem imperdiet a. Phasellus at orci elit, eget tincidunt sapien. In ullamcorper aliquam lorem, vitae blandit massa consequat ut.

## Emphasized
Some of these words *are emphasized*.

## Strongly emphasized
Use two asterisks for **strong emphasis**.

## Unordered list
- li 1
- li 2
- li 3
- li 4

## Ordered list
1. li 1
2. li 2
3. li 3
4. li 4

## Links
This is an [example link](http://example.com/).

## Images
![alt text](http://placekitten.com/200/300 "Title")

## Code
I strongly recommend against using any `<blink>` tags.

I wish SmartyPants used named entities like `&mdash;`
instead of decimal-encoded entites like `&#8212;`.

## Hortizontal rules
* * *

***

*****

- - -

---------------------------------------

## Blockquote
> Why am I dying to live,
> If I'm just living to die.
> > Nested block quote.

## Code block
{% codeblock testing.rb %}
#administer Hana
require 'fileutils'
class Admin < Thor
  include Thor::Actions
  
  desc 'install', 'Install Hana for the first time.'
  def install
    if File.directory? "#{ENV['HOME']}/.hana"
      return if answer == 'n' || answer == 'no'
      FileUtils.rm_rf "#{ENV['HOME']}/.hana"
      say_status :admin, "Hana directory deleted.", :yellow
    end
    Dir.chdir "#{ENV['HOME']}" do
      FileUtils.mkdir_p ".hana/data"
      say_status :admin, "Hana directory created.", :yellow
      Dir.chdir "#{ENV['HOME']}/.hana/data" do
        FileUtils.touch "projects.yml"
        say_status :admin, "projects.yml created.", :yellow
      end
    end
    FileUtils.cp "#{File.dirname(__FILE__)}/settings/config.rb", "#{ENV['HOME']}/.hana"
    say_status :admin, "config.rb copied.", :yellow
    say_status :admin, "Configuration files for Hana are located in #{ENV['HOME']}/.hana", :yellow
  end
  
  desc 'projects', 'Open projects.yml in $editor.'
  def projects
    
  end
end
{% endcodeblock %}



