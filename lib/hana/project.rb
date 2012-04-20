require 'yaml'
require "thor"
# Manages project file tasks
class Project < Thor
  include Thor::Actions
  
  # fix help screens
  def self.banner(task, namespace = true, subcommand = false)
    "#{basename} #{task.formatted_usage(self, true, subcommand)}"
  end
  
  # Task: create a project
  desc 'create [PROJECTNAME]', 'Creates project.'
  method_option :type, :aliases => "-t", :type => :string, :desc => "Type of project."
  method_option :version, :aliases => "-v", :type => :string, :desc => "Which version do you want?"
  def create project_name=nil
    # load projects yaml
    @projects = YAML.load_file "#{ENV['HOME']}/.hana/data/projects.yml"
    # ask questions if tag args don't exist
    if options.empty?
      if project_name.nil?
        valid_name = false
        until valid_name == true
          name = ask 'Name of project: '
          valid_name = valid? @projects, name
          say_status :ERROR, "#{name} already exists.  Please enter a different project name.", :red if not valid_name
        end
      else
        abort "ERROR: #{project_name} already exists.  Please enter a different project name." if not valid? @projects, project_name
        name = project_name
      end
      type = ask 'What kind of project?: '
      version = ask 'What version?: '
      project = HanaUtil::Proj.new name, type, version, $deploy_dir, $source_dir, false
    else # tag arguments exist, create the project
      if project_name.nil?
        say_status :error, 'Project name required.  Please try again.', :red
        return
      end
      project = HanaUtil::Proj.new project_name, options[:type], options[:version], $deploy_dir, $source_dir, false
      abort "ERROR: #{project.name} already exists.  Please enter a different project name." if not valid? @projects, project.name
    end
    
    # check if projects yaml file is empty.
    if @projects.is_a? Array
      @projects << project
    else
      @projects = [project] # is empty push new project in an array
    end
    
    fetch :tomcat
    fetch project
    setup project
    write_to_yaml @projects
    
    say_status :finished, "#{project.name} created.  Don't forget to switch to the project.", :green
  end # end of create
  
  # Task: switch project
  desc 'switch PROJECTNAME', 'Switches current project'
  def switch project_name
    @projects = YAML.load_file "#{ENV['HOME']}/.hana/data/projects.yml"
    if @projects.is_a? Array
      switched = false
      @projects.each do |project|
        if project.name == project_name
          abort "#{project_name} is already set to the current project. :)" if project.current == true
          project.current = true
          switched = true
        else
          project.current = false
        end
      end
      if not switched
        abort "ERROR:  #{project_name} does not exist.  Try creating it first."
      end
      
      write_to_yaml @projects
      say_status :switched, "Project switched to: #{project_name}", :green
    else
      say_status :error, "No projects exist.  Try creating one first.", :red
    end
  end # end of switch
  
  # Task: return current project
  desc 'current', 'Shows current project.'
  def current
    p = HanaUtil::Project.new
    current = p.get_current
    if current
      say_status :current, "#{current.name} // #{current.type} // #{current.version}", :green
    else
      say_status :error, "There is no current project.", :red
    end
  end
  
  desc 'list', 'List all projects'
  method_option :type, :aliases => "-t", :type => :string, :desc => "List all with the same project type."
  method_option :version, :aliases => "-v", :type => :string, :desc => "List all with the same version."
  def list
    projects = HanaUtil::Project.new.list
    
    # filter if there are options
    if options[:type] or options[:version]
      projects = projects.find_all {|p| p.type == options[:type]} if options[:type]
      projects = projects.find_all {|p| p.version == options[:version]} if options[:version]
    end
    
    if projects.length == 0
      say_status :error, "No projects matched criteria. :(", :red
      return
    end
    # sort by project name
    projects.sort_by! do |p|
      p.name
    end

    puts '------------------------------------------------------------'
    projects.each_with_index do |p, index|
      if p.current
        say_status :project, "* #{p.name} // #{p.type} // #{p.version}", :cyan
      else
        say_status :project, "#{p.name} // #{p.type} // #{p.version}", :green
      end
    end
    puts '------------------------------------------------------------'
    puts "* = current"
  end
  
  # Task: create a project
  desc 'add [PROJECTNAME]', 'Adds existing project to yml.'
  method_option :type, :aliases => "-t", :type => :string, :desc => "Type of project."
  method_option :version, :aliases => "-v", :type => :string, :desc => "Which version do you want?"
  def add project_name=nil
    # load projects yaml
    @projects = YAML.load_file "#{ENV['HOME']}/.hana/data/projects.yml"
    # ask questions if tag args don't exist
    if options.empty?
      if project_name.nil?
        valid_name = false
        until valid_name == true
          name = ask 'Name of project: '
          valid_name = valid? @projects, name
          say_status :ERROR, "#{name} already exists.  Please enter a different project name.", :red if not valid_name
        end
      else
        abort "ERROR: #{project_name} already exists.  Please enter a different project name." if not valid? @projects, project_name
        name = project_name
      end
      type = ask 'What kind of project?: '
      version = ask 'What version?: '
      project = HanaUtil::Proj.new name, type, version, $deploy_dir, $source_dir, false
    else # tag arguments exist, create the project
      if project_name.nil?
        say_status :error, 'Project name required.  Please try again.', :red
        return
      end
      project = HanaUtil::Proj.new project_name, options[:type], options[:version], $deploy_dir, $source_dir, false
      abort "ERROR: #{project.name} already exists.  Please enter a different project name." if not valid? @projects, project.name
    end
    
    # check if projects yaml file is empty.
    if @projects.is_a? Array
      @projects << project
    else
      @projects = [project] # is empty push new project in an array
    end
    
    write_to_yaml @projects
    
    say_status :finished, "#{project.name} added.", :green
  end # end of create
  
  desc 'delete [PROJECTNAME]', 'Deletes a project.'
  def delete project_name
    if project_name.nil?
      say_status :error, 'Project name required as argument. Try again.', :red
      return
    end
    
    @projects = YAML.load_file "#{ENV['HOME']}/.hana/data/projects.yml"
    @projects.delete_if { |p| p.name == project_name }
    write_to_yaml @projects
    say_status :delete, "#{project_name} has been removed from tracking."
  end
  
#----------------------PRIVATE------------------------
  private
  # Check if duplicate project is trying to be created
  def valid? projects, pname
    return true if not projects.is_a? Array
    @projects.each do |project|
      if project.name == pname
        return false
      end
    end
    return true
  end
  
  # Write to projects.yml file
  def write_to_yaml projects
    File.open("#{ENV['HOME']}/.hana/data/projects.yml", 'w') do |f|
      f.write(projects.to_yaml)
      f.close
    end
  end
  
  # fetch project type
  def fetch obj
    require 'curb'
    if obj.instance_of? HanaUtil::Proj
      case obj.type
      when 'uportal'
        if obj.version == 'master'
          say_status :uportal, "Cloning from github/master..."
          Dir.chdir "#{$source_dir}" do
            system "git clone #{$uportal_git_url} #{obj.name}-src"
          end
          return
        end
        if File.exists? "#{$source_dir}/.uPortal-#{obj.version}.tar.gz"
          say_status :uportal, "Found cached file.  Using it.", :green
          return
        end
        url = "#{$uportal_download_url}/uPortal-#{obj.version}/uPortal-#{obj.version}.tar.gz"
        file = "#{$source_dir}/.uPortal-#{obj.version}.tar.gz"
        say_status :uportal, "Downloading uPortal...", :green
      when 'cas'
        if File.exists? "#{$source_dir}/.cas-server-#{obj.version}-release.tar.gz"
          say_status :cas, "Found cached CAS file.  Using it.", :green
          return
        end
        url = "#{$cas_download_url}/cas-server-#{obj.version}-release.tar.gz"
        file = "#{$source_dir}/.cas-server-#{obj.version}-release.tar.gz"
        say_status :cas, "Downloading CAS...", :green
      else
        abort "Unknown project type. :("
      end
    elsif obj == :tomcat
      if File.exists? "#{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
        say_status :tomcat, "Found cached Tomcat file.  Using it.", :green
        return
      end
      url = "#{$tomcat_download_url}/apache-tomcat-6.0.35.tar.gz"
      file = "#{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
      say_status :tomcat, "Downloading Tomcat 6.0.35...", :green
    end
    
    curl = Curl::Easy.new(url)
  	curl.on_body {
      |d| f = File.open(file, 'a') {|f| f.write d}
    }
    curl.perform
    
  end
  
  # setup uportal
  def setup obj
    # deploy tomcat
    Dir.chdir($deploy_dir) do
      say_status :tomcat, "Extracting tomcat.", :green
      system "tar -xzf #{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
      system "mv #{$deploy_dir}/apache-tomcat-6.0.35 #{$deploy_dir}/#{obj.name}-tomcat"
      say_status :tomcat, "Configuring Tomcat.", :green
      gsub_file "#{$deploy_dir}/#{obj.name}-tomcat/conf/catalina.properties", "shared.loader=", "shared.loader=${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar", :verbose => false
      say_status :tomcat, "Configuring catalina.properties.", :green
      gsub_file "#{$deploy_dir}/#{obj.name}-tomcat/conf/server.xml", 'redirectPort="8443"', 'redirectPort="8443" emptySessionPath="true" compression="on" compressableMimeType="text/html,text/xml,text/plain"', :verbose => false
      say_status :tomcat, "Configuring server.xml.", :green
    end
    
    # setup based on type of project
    Dir.chdir($source_dir) do
      if obj.type == 'uportal'
        if obj.version != 'master'
          say_status :uportal, "Setting up uPortal.", :green
          system "tar -xzf #{$source_dir}/.uPortal-#{obj.version}.tar.gz"
          system "mv #{$source_dir}/uPortal-#{obj.version} #{$source_dir}/#{obj.name}-src"
          say_status :uportal, "Extracted to folder: #{$source_dir}/#{obj.name}-src", :green
        end
        Dir.chdir("#{$source_dir}/#{obj.name}-src") do
          say_status :uportal, "Configuring build.properties.", :green
          system "cp build.properties.sample build.properties"
          gsub_file "#{$source_dir}/#{obj.name}-src/build.properties", "@server.home@", "#{$deploy_dir}/#{obj.name}-tomcat", :verbose => false
        end
      elsif obj.type == 'cas'
        say_status :cas, "Setting up CAS.", :green
        system "tar -xzf #{$source_dir}/.cas-server-#{obj.version}-release.tar.gz"
        Dir.chdir("#{$source_dir}/cas-server-#{obj.version}/modules") do
          say_status :cas, "Installing CAS to #{$deploy_dir}/#{obj.name}-tomcat/webapps", :green
          system "cp cas-server-webapp-#{obj.version}.war #{$deploy_dir}/#{obj.name}-tomcat/webapps"
          say_status :cas, "Cleaning up CAS source files.", :green
          system "rm -r #{$source_dir}/cas-server-#{obj.version}"
        end
      end
    end
  end
end
