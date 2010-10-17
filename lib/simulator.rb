#!/usr/bin/env ruby
#  simulator
#
#  Created by Paolo Bosetti on 2010-09-21.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#
require 'socket'
require 'yaml'

SOCKET = "/tmp/sim_socket.sok"

class Simulator
  attr_accessor :socket_addr, :di, :ai, :t
  def initialize()
    @socket_addr = SOCKET
    @boot_time = Time.now
    @register = 0
    @running = false
    @di = []
    @ai = []
    @t = []
  end
  
  def boot
    @boot_time = Time.now
    @running  = true
    begin
      sock = UNIXServer.open(@socket_addr)
    rescue Errno::EADDRINUSE => e
      warn "Deleting stale socket"
      system "rm #{@socket_addr}"
      retry
    end
    puts "Awaiting connections"
    @server_thread = Thread.start(sock) do |sock|
      s_in = sock.accept
      while @running do
        ch = s_in.recvfrom(1)[0]
        result = parse(ch, true)
        if result then
          begin
            s_in.send(result.to_s + "\n>\n", 0)
          rescue Errno::EPIPE
            @running = false
          end
        end
      end
      [s_in, sock].each {|s| s.close}
    end
  end
  
  def eval_input(port,i)
    case port[i]
    when Proc
      return port[i].call
    else 
      return port[i]
    end
  end
  
  %w|di ai|.each do |key|
    define_method(key) do |i|
      obj = instance_variable_get("@#{key}")[i]
      case obj
      when Proc
        return obj.call(((Time.now - @boot_time)*1000).to_i)
      else 
        return obj
      end
    end
  end
  
  def wait_for_quit
    if @server_thread
      @server_thread.join
      @server_thread = nil
      system "rm #{@socket_addr}"
    end
  end
  
  def parse(ch, echo=false)
    print ch if echo
    result = nil
    case ch
    when /[0-9]/
      @register = @register * 10 + ch.to_i
    when 'a'
      if (@register > 0 && @register <= @ai.size) then
        result = ai(@register)
      else
        inputs = []
        @ai.size.times {|i| inputs[i] = ai(i)}
        result = YAML.dump(inputs)
      end
      @register = 0
    when 'd'
      if (@register > 0 && @register <= @di.size) then
        result = di(@register)
      else
        inputs = []
        @di.size.times {|i| inputs[i] = di(i)}
        result = YAML.dump(inputs)
      end
      @register = 0
    when 't'
      if (@register > 0 && @register <= @t.size) then
        result = @t[@register][:temp]
      else
        result = YAML.dump(@t)
      end
      @register = 0
    when 's'
      result = YAML.dump(@t.map {|h| h[:address]})
    when 'Q'
      @running = false
    else
      result = "Boot message"
    end
    result
  end
  
end


if ($0 == __FILE__) then
  sim = Simulator.new
  sim.ai = [0,127,255,511,767,1023,lambda {|t| t}]
  sim.di = [0,1,0,1,0,1,0]
  sim.t = [
    {:address=>"28200231020000A3", :temp=>27.12}, 
    {:address=>"283E223102000013", :temp=>27.19}, 
    {:address=>"28951031020000B0", :temp=>27.19}]
  sim.boot
  sim.wait_for_quit
end