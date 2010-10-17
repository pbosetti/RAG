#!/usr/bin/env ruby
#  extconf
#
#  Created by Paolo Bosetti on 2010-10-05.
#  Copyright (c) 2010 University of Trento. All rights reserved.
#

require 'mkmf'
puts "\n*** Preparing Makefile for ruby #{RUBY_VERSION}\n\n"
if RUBY_VERSION =~ /^1.9/ then
  $CPPFLAGS += " -DRUBY_19"
end

create_makefile("CBuffer")