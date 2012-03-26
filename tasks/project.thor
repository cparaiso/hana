require 'yaml'
# Manages project file tasks
class Project < Thor
  include Thor::Actions
  
  # Task: create a project
  desc 'create [PROJECTNAME]', 'Creates project.'
  method_option :type, :aliases => "-t", :type => :string, :desc => "Type of project."
  method_option :version, :aliases => "-v", :type => :string, :desc => "Which version do you want?"
  def create project_name=nil
    # load projects yaml
    @projects = YAML.load_file 'data/projects.yml'
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
      project = Proj.new name, type, version, $deploy_dir, $source_dir, false
    else # tag arguments exist, create the project
      if project_name.nil?
        say_status :error, 'Project name required.  Please try again.', :red
        return
      end
      project = Proj.new project_name, options[:type], options[:version], $deploy_dir, $source_dir, false
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
    @projects = YAML.load_file 'data/projects.yml'
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
    @projects = YAML.load_file 'data/projects.yml'
    abort "There are no projects.  Try creating one first." if not @projects.is_a? Array
    @projects.each do |project|
      if project.current == true
        say_status :current, "Current project: #{project.name} // #{project.type} // #{project.version}", :green
        return project
      end
    end
    say_status :error, "There is no current project.", :red
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
    File.open('data/projects.yml', 'w') do |f|
      f.write(projects.to_yaml)
      f.close
    end
  end
  
  # fetch project type
  def fetch obj
    require 'curb'
    if obj.instance_of? Proj
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
