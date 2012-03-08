require 'yaml'
# uportal tasks
class Uportal < Thor
  include Thor::Actions
  
  desc 'init', 'ant initportal'
  method_option :skip_test, :aliases => "-s", :type => :boolean, :default => false, :desc => "Type of project."
  def init
    p = Project.new
    current = p.current
    if not current.type == 'uportal'
      say_status :error, "The current project's type is not uportal."
      return
    end
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      if options[:skip_test]
        system "ant initportal -Dmaven.test.skip=true"
      else
        system "ant initportal"
      end
    end
  end
  
  desc 'war', 'ant deploy-war'
  def war
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant deploy-war"
    end
  end
  
  desc 'ear', 'ant deploy-ear'
  def ear
    Dir.chdir("#{current.source_dir}/#{current.name}-src") do
      system "ant deploy-ear"
    end
  end
  
  
end