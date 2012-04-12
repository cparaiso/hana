require "thor"
class Tomcat < Thor
  include Thor::Actions
  
  # fix help screens
  def self.banner(task, namespace = true, subcommand = false)
    "#{basename} #{task.formatted_usage(self, true, subcommand)}"
  end
  
  desc 'start', 'Start Tomcat.'
  def start
    p = Projekt.new
    current = p.get_current
    if not current
      say_status :error, "There is no current project.", :red
      return
    end
    say_status :tomcat, 'Starting Tomcat...', :green
    Dir.chdir("#{current.deploy_dir}/#{current.name}-tomcat/bin") do
      system "./startup.sh"
      system "tail -f ../logs/catalina.out"
    end
  end
  
  desc 'stop', 'Stop Tomcat.'
  def stop
    p = Projekt.new
    current = p.get_current
    if not current
      say_status :error, "There is no current project.", :red
      return
    end
    say_status :tomcat, 'Stopping Tomcat...', :green
    Dir.chdir("#{current.deploy_dir}/#{current.name}-tomcat/bin") do
      system "./shutdown.sh"
      system "tail -f ../logs/catalina.out"
    end
  end 
end