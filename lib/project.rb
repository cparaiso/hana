class Projekt
  require 'yaml'
  
  def initialize
    @projects = YAML.load_file "#{ENV['HOME']}/.hana/data/projects.yml"
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