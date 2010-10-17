##!/usr/bin/env ruby
#  buffer
#
#  Created by Paolo Bosetti on 2010-10-05.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#
LIB_DIR = File.dirname __FILE__
begin
  require "#{LIB_DIR}/CBuffer"
rescue LoadError
  warn "CBuffer library not found. I'll try to build it from source..."
  output = `cd #{LIB_DIR}; ruby extconf.rb; make`
  warn output
end


class CBuffer < Array
  attr_accessor :head
  attr_reader :mean, :sd
  def initialize( size=0, obj=0.0 )
    raise ArgumentError unless obj.kind_of? Numeric
    @head = 0
    @mean = nil
    @sd = nil
    super
  end
  
  # def <<(e)
  #   raise ArgumentError unless e.kind_of? Numeric
  #   self[@head] = e.to_f
  #   @head = (@head + 1) % self.size
  # end
  # 
  # def statistics
  #   @mean = self.inject(0) {|s,i| s + i} / self.size
  #   @sd = Math::sqrt(self.inject(0) {|s,i| s + (i - @mean) ** 2} / (self.size - 1))
  #   [@mean, @sd]
  # end
  
end


if ($0 == __FILE__) then
  b = CBuffer.new(5)
  p b
  puts b.head
  b << 1
  b << 2
  b << 3
  b << 4
  b << 5
  b << 6
  p b
  puts b.statistics
end