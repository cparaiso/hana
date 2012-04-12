#administer Hana
require 'fileutils'
class Admin < Thor
  include Thor::Actions
  
  desc 'install', 'Install Hana for the first time.'
  def install
    if File.directory? "#{ENV['HOME']}/.hana"
      answer = ask "Hana has been previously installed.  Do you want to clear out #{ENV['HOME']}/.hana? [y/n] "
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