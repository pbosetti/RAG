##!/usr/bin/env ruby
#  dispatcher
#
#  Created by Paolo Bosetti on 2010-10-08.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#

require 'drb'

require "./lib/arduino"
require "./lib/CBuffer"
require "./lib/config"

class Master
  include DRbUndumped 
  attr_reader :tables, :hosts
  
  def initialize(hosts)
    @hosts = hosts
    @drbs = []
    @tables = []
    DRb.start_service
    @hosts.each do |h|
      obj = DRbObject.new(nil, "druby://#{h}")
      obj.add_observer self
      @drbs << obj
    end
  end
  
  def run(n)
    @tables = []
    @drbs.each_with_index do |d,i|
      d.id = i
      d.run(n)
    end
  end
  
  def update(id, table)
    @tables[id] = table
  end
end


hosts = %w(localhost:9000)
master = Master.new hosts
puts "Sending request..."
master.run 5
puts "Awaiting reply..."
sleep 0.1 until master.tables.size == hosts.size
puts "Result:"
p master.tables
puts YAML.dump(master.tables)