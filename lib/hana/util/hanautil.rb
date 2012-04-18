module HanaUtil
  class Project
    require 'yaml'
    def initialize
      begin
        @projects = YAML.load_file "#{ENV['HOME']}/.hana/data/projects.yml"
      rescue Errno::ENOENT
        puts "Hana could not find #{ENV['HOME']}/.hana/data/projects.yml - Please create it or run 'hana admin install'"
        exit
      end
    end
  
    def get_current
      begin
        @projects.each do |project|
          if project.current == true
            return project
          end
        end
      rescue
        false
      end
    end
    
    def list
      @projects
    end
    
    def is_uportal
      current = get_current
      return false if not current.type == 'uportal'
      current
    end
  
    def is_cas
      current = get_current
      return false if not current.type == 'cas'
      current
    end
  end

  # structures
  Proj = Struct.new :name, :type, :version, :deploy_dir, :source_dir, :current
end