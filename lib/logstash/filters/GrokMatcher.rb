# encoding: utf-8

# Utiliy Class to handle pattern files and corresponding matchers 
#
# It is only intended to be used with DktGrok

require "logstash/logging"
require "grok-pure" 

class  GrokMatcher
  
  attr_accessor :grok
  attr_accessor :matcherList
  
  def initialize()
    @grok = Grok.new
    @matcherList = Array.new
  end
    
  def addPatternFile(filename)
    @grok.add_patterns_from_file(filename)
  end
  
  def addMatcherFile(filename)
    # add every single line as a pattern to compile
    if File.exists?(filename)
      matcherFile = File.open(filename,  "r")
      matcherFile.each do |matcherLine|
        matcherLine = matcherLine.chomp        
        if !matcherLine.empty?
          @matcherList << matcherLine
        end
      end
    else
      puts " ERROR : DKT Grok -> Matcher File not Found #{filename}"
    end

  end
  
end