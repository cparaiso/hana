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
  
  desc 'import FILE', 'ant data-import -D[arg]'
  def import filename
    current = is_uportal
    if not current
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant data-import -D#{current.source_dir}/#{current.name}-src/uportal-war/#{filename}"
      say_status :uportal, "#{current.source_dir}/#{current.name}-src/uportal-war/#{filename}", :green
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