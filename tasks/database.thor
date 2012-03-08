class Db < Thor
  include Thor::Actions
  
  desc 'start', 'Start database'
  def start
    p = Project.new
    current = p.current
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
    p = Project.new
    current = p.current
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