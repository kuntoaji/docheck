begin
  require File.expand_path('../../docheck.rb', __FILE__)
rescue LoadError
  require 'rubygems'
  require File.expand_path('../../docheck.rb', __FILE__)
end

require 'optparse'

begin
  OptionParser.new do |opts|
    opts.banner = "Usage: docheck [basename]. Example: docheck google"

    opts.on("-v", "--version", "Show version") do
      puts "Docheck #{Docheck::VERSION}"
    end

    opts.on("-n", "--name NAME", "Execute domain name checker") do |name|
      Docheck::Application.new(name).print
    end

    opts.on_tail("-h", "--help", "Show help") do
      puts opts
      exit
    end
  end.parse!
rescue OptionParser::InvalidOption
  puts "Invalid option"
rescue OptionParser::MissingArgument
  puts "Missing argument"
end
