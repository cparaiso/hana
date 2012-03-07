require 'yaml'

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
          puts "ERROR: #{name} already exists.  Please enter a different project name." if not valid_name
        end
      else
        abort "ERROR: #{project_name} already exists.  Please enter a different project name." if not valid? @projects, project_name
        name = project_name
      end
      type = ask 'What kind of project?: '
      version = ask 'What version?: '
      project = Proj.new name, type, version, $deploy_dir, $source_dir, false
    else # tag arguments exist, create the project
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
    
    puts "#{project.name} created.  Don't forget to switch to the project."
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
      puts "Project switched to: #{project_name}"
    else
      puts "No projects exist.  Try creating one first."
    end
  end # end of switch
  
  # Task: return current project
  desc 'current', 'Shows current project.'
  def current
    @projects = YAML.load_file 'data/projects.yml'
    abort "There are no projects.  Try creating one first." if not @projects.is_a? Array
    @projects.each do |project|
      if project.current == true
        puts "Current project: #{project.name} // #{project.type} // #{project.version}"
        return
      end
    end
    puts "There is no current project."
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
    puts "Fetching stuff..."
    if obj.instance_of? Proj
      case obj.type
      when 'uportal'
        if File.exists? "#{$source_dir}/.uPortal-#{obj.version}.tar.gz"
          puts "Found cached file.  Using it..."
          return
        end
        url = "#{$uportal_download_url}/uPortal-#{obj.version}/uPortal-#{obj.version}.tar.gz"
        file = "#{$source_dir}/.uPortal-#{obj.version}.tar.gz"
        puts "Downloading uPortal..."
      when 'cas'
        if File.exists? "#{$source_dir}/.cas-server-#{obj.version}-release.tar.gz"
          puts "Found cached CAS file.  Using it..."
          return
        end
        url = "#{$cas_download_url}/cas-server-#{obj.version}-release.tar.gz"
        file = "#{$source_dir}/.cas-server-#{obj.version}-release.tar.gz"
        puts "Downloading CAS..."
      else
        abort "Unknown project type. :("
      end
    elsif obj == :tomcat
      if File.exists? "#{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
        puts "Found cached Tomcat file.  Using it..."
        return
      end
      url = "#{$tomcat_download_url}/apache-tomcat-6.0.35.tar.gz"
      puts url
      file = "#{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
      puts "Downloading Tomcat 6.0.35..."
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
      puts "Extracting tomcat... #{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
      system "tar -xzf #{$deploy_dir}/.apache-tomcat-6.0.35.tar.gz"
      system "mv #{$deploy_dir}/apache-tomcat-6.0.35 #{$deploy_dir}/#{obj.name}-tomcat"
      puts "Configuring Tomcat..."
      gsub_file "#{$deploy_dir}/#{obj.name}-tomcat/conf/catalina.properties", "shared.loader=", "shared.loader=${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar", :verbose => false
      gsub_file "#{$deploy_dir}/#{obj.name}-tomcat/conf/server.xml", 'redirectPort="8443"', 'redirectPort="8443" emptySessionPath="true" compression="on" compressableMimeType="text/html,text/xml,text/plain"', :verbose => false
      # TODO: settings for tomcat need to be.... set
    end
    
    # setup based on type of project
    Dir.chdir($source_dir) do
      if obj.type == 'uportal'
        puts "Setting up uPortal..."
        system "tar -xzf #{$source_dir}/.uPortal-#{obj.version}.tar.gz"
        system "mv #{$source_dir}/uPortal-#{obj.version} #{$source_dir}/#{obj.name}-src"
        puts "Extracted to folder: #{$source_dir}/#{obj.name}-src"
        Dir.chdir("#{$source_dir}/#{obj.name}-src") do
          puts "Configuring build.properties..."
          system "cp build.properties.sample build.properties"
          gsub_file "#{$source_dir}/#{obj.name}-src/build.properties", "@server.home@", "#{$deploy_dir}/#{obj.name}-tomcat", :verbose => false
        end
      elsif obj.type == 'cas'
        puts "Setting up CAS..."
        system "tar -xzf #{$source_dir}/.cas-server-#{obj.version}-release.tar.gz"
        Dir.chdir("#{$source_dir}/cas-server-#{obj.version}/modules") do
          puts "Installing CAS to #{$deploy_dir}/#{obj.name}-tomcat/webapps"
          system "cp cas-server-webapp-#{obj.version}.war #{$deploy_dir}/#{obj.name}-tomcat/webapps"
          puts "Cleaning up CAS source files..."
          system "rm -r #{$source_dir}/cas-server-#{obj.version}"
        end
      end
    end
    
  end
  
  # setup cas
  def setup_cas
    
  end
end
