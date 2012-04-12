#!/usr/bin/env ruby
require_relative "project"
require_relative "database"
require_relative "tomcat"
require_relative "uportal"
require_relative "admin"
module Hana
  def self.const_missing(c)
    Object.const_get(c)
  end
end
