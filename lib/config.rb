##!/usr/bin/env ruby
#  untitled
#
#  Created by Paolo Bosetti on 2010-09-14.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#

require "yaml"

class YamlConfig
  include Enumerable
  attr_reader :path
  def initialize(path)
    @path = path
    @cfg = File.open(@path) { |file| YAML.load(file) }
  rescue Errno::ENOENT
    warn "Config file #{@path} does not exist!"
  end
  
  def empty?
    @cfg ? false : true
  end
  
  def make(hash)
    raise unless hash.kind_of? Hash
    @cfg = hash
    File.open(@path, "w") { |file| YAML.dump(hash, file) }
  end
  
  def merge(hash)
    raise unless hash.kind_of? Hash
    self.make(@cfg.merge(hash))
  end
  
  def to_h
    @cfg
  end
  
  def method_missing(name, *args, &block)
    if @cfg[name] then
      return @cfg[name] 
    else
      raise ArgumentError, "Not such a config key: #{name}"
    end
  end
  
  def each
    @cfg.each do |k,v|
      yield k, v
    end
  end

end

if (__FILE__ == $0) then
  cfg = YamlConfig.new("test.yaml")
  if cfg.empty? then
    puts "Initializing"
    h = {a:1, b:2, c:[1,2,3], d:"test"}
    cfg.make h
  end
  cfg.merge d:"test2", b:3
  puts "b: #{cfg.c.inspect}"
  cfg.each do |k,v|
    puts "#{k} => #{v.inspect}"
  end
  p cfg.all? {|k,v| v}
  p cfg.pippo
end

