# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/environment"
require "set"
require "grok-pure"
require "logstash/filters/GrokMatcher"

# This filter will load pattern and matcher pattern, one per file in conf folders.
# It performs the matching for each log, depending on the event["application"] value.
# This value should equals the filenma ein directory structure . for example :
# int rule file :
# ....
#  dktgrok {
#    common_dir => "<Common_path>"
#    patterns_dir => "<Pattern_path>"
#    matchers_dir => "<Matcher_path>"
#   }
#
# if event["applicationName"] => "Some_app"
# 
# folder and files shoud be
#  
#  <Pattern_path>/<Some_app>.pattern
#  <Matcher_path>/<Some_app>.matcher
#
class LogStash::Filters::Dktgrok < LogStash::Filters::Base

  config_name "dktgrok"
  
  # Common directory
  config :common_dir, :validate => :string, :default => ""
  
  # Pattern directory
  config :patterns_dir, :validate => :string, :default => ""
  
  # matcher directory
  config :matchers_dir, :validate => :string, :default => ""      
    
  # class variables
  @@grokMatcherMap = Hash.new
  @@commonFileList = Array.new
  @@patternSuffix = ".matcher"
  
  ### initialize method

  public
  def initialize(params)
    super(params)
  end
    
  ### register method
  
  public
  def register
    
    # get filename for each common pattern file
    if File.directory?(@common_dir)
      path_common = File.join(@common_dir, "*")
      Dir.glob(path_common).each do |commonFile|
        @logger.info? and @logger.info("DKT Grok -> Registering common pattern file", :commonFile => commonFile)
        @@commonFileList << commonFile
      end # Dir.glob(path_common).each do |file|
    end #  if File.directory?(@common_dir)
    
    # get filename for each pattern file
    if File.directory?(@patterns_dir)
      path_common = File.join(@patterns_dir, "*")
      Dir.glob(path_common).each do |patternFile|
        basename = File.basename(patternFile.to_s, ".*")
        @logger.info? and @logger.info("DKT Grok -> Creating grok and matchers for application :", :basename => basename )
        # create grokmatcher and stores it in map ( key = file basename )
        grokMatcher = GrokMatcher.new 
        # add common files
        @@commonFileList.each do |commonFile|
          grokMatcher.addPatternFile(commonFile)
        end
        # add specific application pattern file
        grokMatcher.addPatternFile(patternFile)        
        # add corresponding matcher file
        matcherFilePath = @matchers_dir << File::SEPARATOR << basename << @@patternSuffix
        grokMatcher.addMatcherFile(matcherFilePath)
        
        @@grokMatcherMap[basename.to_s] = grokMatcher
        
      end # Dir.glob(path_common).each do |file|
    end #  if File.directory?(@common_dir)
    
  end # def register

  ## Filter : for each event, application tag must be available and fullfilled 
  # if not , no action is taken and the event is discarded
  # if so, a specific grok process is ran on each associated matcher pattern
  
  public
  def filter(event)
    applicationName = event["application"]
    if @@grokMatcherMap.has_key?(applicationName)
      appGrok =  @@grokMatcherMap[applicationName.to_s].grok
      matcherList =  @@grokMatcherMap[applicationName.to_s].matcherList
      input = event["message"]     
      # loop on matchers
      matcherList.each do |currentMatcher|
        # grok compile
        appGrok.compile(currentMatcher)
        # grok match ?
        match = appGrok.match(input.to_s)
            
        if match
          @logger.info? and @logger.info("DKT Grok -> Match Found", :currentMatcher => currentMatcher )
          # put the captures into event 
          match.captures.keys.each do |captureKey|
            event["#{captureKey}"] = "#{match.captures[captureKey].join()}"
          end #  match.captures.keys.each do |captureKey|
        end # if match  
      
      end #  appGrok.matcherList.each do |currentMatcher|
    end # if @@grokMatcherMap.has_key?(applicationName)
  end # filter
 
end # class LogStash::Filters::Dktgrok
