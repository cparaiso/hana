require 'yaml'
# uportal tasks
class Uportal < Thor
  include Thor::Actions
  
  desc 'init', 'ant initportal'
  method_option :skip_test, :aliases => "-s", :type => :boolean, :default => false, :desc => "Type of project."
  def init
    current = is_uportal
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
  end
  
  desc 'war', 'ant deploy-war'
  def war
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant deploy-war"
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
      say_status :uportal, "#{current.source_dir}/#{current.name}-src/uportal-war/#{filename}", :green
    end
  end
  
  # syncing tomcat changes back to original source
  desc 'sync', 'Sync tomcat files back to source'
  # method_option :sync_skin, :aliases => "-s", :type => :boolean, :default => false, :desc => "Sync skin only."
  # method_option :sync_theme, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sync theme only."
  def sync
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    
    deployed_desktop_skin_dir = "#{current.deploy_dir}/#{current.name}-tomcat/webapps/uPortal/media/skins/universality"
    deployed_theme_dir = "#{current.deploy_dir}/#{current.name}-tomcat/webapps/uPortal/WEB-INF/classes/layout/theme/universality"
    source_desktop_skin_dir = "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/webapp/media/skins"
    source_theme_dir = "#{current.source_dir}/#{current.name}-src/uportal-war/src/main/resources/layout/theme"
    
    if options.empty?
      puts '------------------------------------------------------------'
      say_status :uportal, "Syncing uportal skins.", :green
      system "rsync -ruv --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.aggr*' #{deployed_desktop_skin_dir} #{source_desktop_skin_dir}"
      puts '------------------------------------------------------------'
      say_status :uportal, " Syncing uportal theme.", :green
      system "rsync -ruv --exclude '.DS_Store' --exclude '*svn' --exclude '.sass*' --exclude '*.sggr*' #{deployed_theme_dir} #{source_theme_dir}"
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