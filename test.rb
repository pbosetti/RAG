##!/usr/bin/env ruby
#  test
#
#  Created by Paolo Bosetti on 2010-09-27.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#

class Test
  attr_reader :cfg
  def initialize(args)
    raise ArgumentError, "Must provide a Hash" unless args.kind_of? Hash
    @cfg = args
    2 / 0
  rescue ArgumentError => e
    warn "expecting a Hash"
    p e
    @cfg = {}
  rescue
    warn "error happened"
  end
  
  
end

t = Test.new({a:1, b:2})
p t