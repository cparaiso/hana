class Tomcat < Thor
  include Thor::Actions
  
  desc 'start', 'Start Tomcat.'
  def start
    current = get_current_project
    say_status :tomcat, 'Starting Tomcat...', :green
    Dir.chdir("#{current.deploy_dir}/#{current.name}-tomcat/bin") do
      system "./startup.sh"
      system "tail -f ../logs/catalina.out"
    end
  end
  
  desc 'stop', 'Stop Tomcat.'
  def stop
    current = get_current_project
    say_status :tomcat, 'Stopping Tomcat...', :green
    Dir.chdir("#{current.deploy_dir}/#{current.name}-tomcat/bin") do
      system "./shutdown.sh"
      system "tail -f ../logs/catalina.out"
    end
  end
  
  private
  def get_current_project
     p = Project.new
     p.current
  end
end