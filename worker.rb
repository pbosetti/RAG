##!/usr/bin/env ruby
#  worker
#
#  Created by Paolo Bosetti on 2010-10-07.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#

require 'drb'
require 'drb/observer'

require "./lib/arduino"
require "./lib/CBuffer"
require "./lib/config"

CFG_PATH = "./worker.yaml"
STDOUT.sync = true

class Worker 
  include DRb::DRbObservable
  attr_reader :table
  attr_accessor :id
  
  def initialize(cfg)
    @id = 0
    @cfg = cfg
    @ard = Arduino.new :port => Dir.glob("/dev/tty.usb*")[0], :baud => @cfg.baud
    @ard.connect
    @ard.command('*') {|l| puts l}
    @read_buf = ""
    @ard.command('s', @read_buf) {|l| l + "\n"}
    sensors = YAML.load(@read_buf)
    @table = Table.new(sensors.count) {|n| CBuffer.new(@cfg.window_size)}
    @table.col_names = sensors.map {|s| s[-2..-1]}
    @thread = Thread.new {}
  end
  
  def acquire(cmd)
      @read_buf = ""
      @ard.command(cmd, @read_buf) {|l| l + "\n"}
      if @read_buf =~ /^---/ then
        YAML.load(@read_buf)
      else
        @read_buf
      end
  end
  
  def run(n=1)
    n = 1 unless n > 0
    @thread = Thread.start do
      n.times do |i|
        measures = self.acquire("t")
        @table << measures.map {|m| m[:temp]}
      end
      changed
      notify_observers(@id, @table)
    end unless @thread.alive?
  end
  
  def busy
    @thread.alive?
  end

end 

cfg = YamlConfig.new(CFG_PATH)
if cfg.empty? then
  puts "Initializing new config file"
  h = { port:9000, baud:115200 }
  cfg.make h
end

worker = Worker.new(cfg)
# 5.times do |i|
#   worker.run
#   sleep 0.1
# end
# puts 
# p worker.table
# worker.table.each do |n,c|
#   c.statistics
#   puts "%s: %6.2f, %6.3f" % [n, c.mean, c.sd]
# end

DRb.start_service("druby://localhost:#{cfg.port}", worker) 
DRb.thread.join
