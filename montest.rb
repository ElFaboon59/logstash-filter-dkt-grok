#!/usr/bin/env ruby
#

require "logstash/filters/GrokMatcher"

class Montest
  
  def initialize(grokMatcher)
     @thegrok = grokMatcher
    end
  
end