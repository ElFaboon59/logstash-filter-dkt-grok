#!/usr/bin/env ruby
#

require "rubygems"
require "grok-pure"
require "pp"

grok = Grok.new

# Load some default patterns that ship with grok.
# See also: 
#   http://code.google.com/p/semicomplete/source/browse/grok/patterns/base
grok.add_patterns_from_file("/home/fhameau/workspace/RubyGrokTest/patterns/pure-ruby/base")
grok.add_patterns_from_file("/opt/logstash-1.5.0/conf/common/java.pattern")
grok.add_patterns_from_file("/opt/logstash-1.5.0/conf/pattern/TEST_APPLICATION.pattern")

# Using the patterns we know, try to build a grok pattern that best matches 
# a string we give. Let's try Time.now.to_s, which has this format;
# => Fri Apr 16 19:15:27 -0700 2010

input = "at com.example.myproject.Book.getTitle(Book.java:16)"
pattern = "at %{JAVA_CLASS:class}\.%{JAVAMETHOD:method}\(%{JAVAFILE:file}(?::%{NUMBER:line})?\)"
grok.compile(pattern)
#grok.compile(pattern)
puts "Input: #{input}"
puts "Pattern: #{pattern}"
puts "Full: #{grok.expanded_pattern}"

match = grok.match(input)
if match
  
  puts match.captures
  
  puts "Resulting capture:"
  match.captures.keys.each do |capture|
    puts "#{capture}  #{match.captures[capture].join(" ")}"
  end
end




