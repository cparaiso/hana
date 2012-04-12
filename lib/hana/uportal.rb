require 'yaml'
require 'nokogiri'
require "#{ENV['HOME']}/.hana/config"
require "thor"
# uportal tasks
class Uportal < Thor
  include Thor::Actions
  
  # fix help screens
  def self.banner(task, namespace = true, subcommand = false)
    "#{basename} #{task.formatted_usage(self, true, subcommand)}"
  end
  
  desc 'init', 'ant initportal'
  method_option :skip_test, :aliases => "-s", :type => :boolean, :default => false, :desc => "Skip maven tests."
  def init
    p = Projekt.new
    current = p.is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      if options[:skip_test]
        system "ant clean initportal -Dmaven.test.skip=true"
      else
        system "ant clean initportal"
      end
    end
    say_status :uportal, "Syncing deployed skin/theme files to source.", :green
    deployed_desktop_skin_dir = "#{current.deploy_dir}/#{current.name}-tomcat/webapps/uPortal/media/skins/universality"
    deployed_theme_dir = "#{current.deploy_dir}/#{current.name}-tomcat/webapps/uPortal/WEB-INF/classes/layout/theme/"
    source_desktop_skin_dir = "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/webapp/media/skins"
    source_theme_dir = "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/resources/layout/theme"
    
    system "rsync -ruq --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.aggr*' #{deployed_desktop_skin_dir} #{source_desktop_skin_dir}"
    system "rsync -ruq --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.sggr*' #{deployed_theme_dir} #{source_theme_dir}"
    say_status :uportal, "Ready.", :green
  end
  
  desc 'war', 'ant deploy-war'
  method_option :skip_test, :aliases => "-s", :type => :boolean, :default => false, :desc => "Skip maven tests."
  def war
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      if options[:skip_test]
        system "ant deploy-war -Dmaven.test.skip=true"
      else
        system "ant deploy-war"
      end
    end
  end
  
  desc 'ear', 'ant deploy-ear'
  def ear
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant deploy-ear"
    end
  end
  
  desc 'portlet PATH_TO_PORTLET_WAR_FILE', 'ant deployPortletApp -D[arg]'
  def portlet warfile
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant deployPortletApp -D#{warfile}"
      say_status :uportal, "Portlet deployed.", :green
    end
  end
  
  desc 'import FILE', 'ant data-import -Dfile=[arg]'
  def import filename
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant data-import -Dfile=#{current.source_dir}/#{current.name}-src/uportal-war/#{filename}"
      say_status :uportal, "Importing #{current.source_dir}/#{current.name}-src/uportal-war/#{filename}...", :green
    end
  end
  
  # syncing tomcat changes back to original source
  desc 'sync', 'Sync tomcat files back to source'
  method_option :sync_skin, :aliases => "-s", :type => :boolean, :default => false, :desc => "Sync skin only."
  method_option :sync_theme, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sync theme only."
  def sync
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    
    deployed_desktop_skin_dir = "#{current.deploy_dir}/#{current.name}-tomcat/webapps/uPortal/media/skins/universality"
    deployed_theme_dir = "#{current.deploy_dir}/#{current.name}-tomcat/webapps/uPortal/WEB-INF/classes/layout/theme/"
    source_desktop_skin_dir = "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/webapp/media/skins"
    source_theme_dir = "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/resources/layout/theme"
    
    if options.empty?
      puts '------------------------------------------------------------'
      say_status :uportal, "Syncing uportal skins.", :green
      system "rsync -ruv --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.aggr*' #{deployed_desktop_skin_dir} #{source_desktop_skin_dir}"
      puts '------------------------------------------------------------'
      say_status :uportal, " Syncing uportal theme.", :green
      system "rsync -ruv --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.sggr*' #{deployed_theme_dir} #{source_theme_dir}"
      puts '------------------------------------------------------------'
    elsif options[:sync_skin]
      puts '------------------------------------------------------------'
      say_status :uportal, "Syncing uportal skins.", :green
      system "rsync -ruv --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.aggr*' #{deployed_desktop_skin_dir} #{source_desktop_skin_dir}"
      puts '------------------------------------------------------------'
    elsif options[:sync_theme]
      puts '------------------------------------------------------------'
      say_status :uportal, " Syncing uportal theme.", :green
      system "rsync -ruv --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.sggr*' #{deployed_theme_dir} #{source_theme_dir}"
      puts '------------------------------------------------------------'
    end
  end
  
  desc 'skin', 'Add or delete skins'
  method_option :add, :aliases => "-a", :type => :boolean, :default => false, :desc => "Add skin."
  method_option :default, :aliases => "-d", :type => :string, :default => nil, :desc => "Set default skin."
  def skin skin_name=nil
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal.", :red
      return
    end
    if options.empty?
      if skin_name.nil?
        say_status :error, "Failed: skin name needed as an argument. uportal:skin [skin_name]", :red
        return
      end
      say_status :uportal, "Opening deployed skin directory...", :green
      system "#{$editor} #{current.source_dir}/#{current.name}-src/uportal-war/src/main/webapp/media/skins/universality/#{skin_name}"
    elsif options[:add]
      skin_name = options[:add]
      Dir.chdir "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/webapp/media/skins/universality" do
        if File.directory? skin_name
          say_status :uportal, "#{skin_name} already exists."
          return
        end
        system "cp -R uportal3 #{skin_name}"
        say_status :uportal, "Created skin: #{skin_name}."    
        xml = Nokogiri::XML(File.open 'skinList.xml')
        skin = Nokogiri::XML::Node.new 'skin', xml
        skin_children = {'skin-key'  => skin_name, 'skin-name'  => skin_name, 'skin-description'  => skin_name}
        skin_children.each do |key,value|
          node = Nokogiri::XML::Node.new key, skin
          node.content = value
          skin.add_child node
        end
        xml.xpath('//skins/skin').first.add_previous_sibling skin
        file = File.open 'skinList.xml', 'w'
        file.puts xml.to_xml
        file.close
        say_status :uportal, "Updated skinList.xml."
      end
    elsif options[:default]
      skin_name = options[:default]
      gsub_file "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/data/required_entities/stylesheet-descriptor/DLMXHTML.stylesheet-descriptor.xml", /<default-value>.*<\/default-value>/, "<default-value>#{skin_name}</default-value>"
      # import assumes uportal-war
      invoke :import, ["src/main/data/required_entities/stylesheet-descriptor/DLMXHTML.stylesheet-descriptor.xml"]
      say_status :uportal, "The default skin has been set to: #{skin_name}"
    end
  end

#----------------------PRIVATE------------------------
  private
  def is_uportal
    p = Project.new
    current = p.current
    return false if not current.type == 'uportal'
    current
  end
  
end