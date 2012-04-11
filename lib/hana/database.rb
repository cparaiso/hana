require "#{ENV['HOME']}/.hana/config"
require "#{ENV['HOME']}/.hana/project"
require "thor"
class Db < Thor
  include Thor::Actions
  
  # fix help screens
  def self.banner(task, namespace = true, subcommand = false)
    "#{basename} #{task.formatted_usage(self, true, subcommand)}"
  end
  
  desc 'start', 'Start database'
  def start
    p = Projekt.new
    current = p.is_uportal
    if current.type == 'uportal'
      say_status :uportal, "Starting database.", :green
      Dir.chdir("#{current.source_dir}/#{current.name}-src") do
        system "ant hsql -Dspawn=true"
        say_status :uportal, "Database started.", :green
        
      end
    else
      say_status :error, "#{current.type} does not require a database."
    end
  end
  
  desc 'stop', 'Stop database'
  def stop
    p = Projekt.new
    current = p.is_uportal
    if current.type == 'uportal'
      say_status :uportal, "Stoping database.", :green
      Dir.chdir("#{current.source_dir}/#{current.name}-src") do
        system "ant hsql-shutdown"
        say_status :uportal, "Database stopped.", :green
      end
    else
      say_status :error, "#{current.type} does not require a database."
    end
    
  end
end