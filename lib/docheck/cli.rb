# frozen_string_literal: true

require "optparse"
require_relative "../docheck"

module Docheck
  # The docheck command. #run returns the process exit status.
  class CLI
    EX_OK = 0
    EX_USAGE = 64

    LABELS = {
      available: "Available",
      registered: "Registered",
      unknown: "Unknown (lookup failed)",
      unsupported: "Unsupported (no RDAP server)"
    }.freeze

    def initialize(argv, out: $stdout, err: $stderr, checker: nil)
      @argv = argv.dup
      @out = out
      @err = err
      @checker = checker
      @done = false
    end

    def run
      name = nil
      parser = option_parser { |value| name = value }
      parser.parse!(@argv)
      return EX_OK if @done
      return usage_error(parser, "missing --name") unless name

      print_results((@checker || Checker.new).check(name))
      EX_OK
    rescue OptionParser::ParseError, InvalidNameError => e
      usage_error(parser, e.message)
    end

    private

    def option_parser(&on_name)
      OptionParser.new do |opts|
        opts.banner = "Usage: docheck -n NAME   (example: docheck -n google)"
        opts.on("-n", "--name NAME", "Check NAME against each TLD", &on_name)
        opts.on("-v", "--version", "Show version") { finish("docheck #{VERSION}") }
        opts.on("-h", "--help", "Show help") { finish(opts.help) }
      end
    end

    def finish(text)
      @out.puts text
      @done = true
    end

    def usage_error(parser, message)
      @err.puts "docheck: #{message}"
      @err.puts parser.help
      EX_USAGE
    end

    def print_results(results)
      results.group_by(&:status).sort_by { |status, _| LABELS.keys.index(status) }.each do |status, group|
        @out.puts "#{LABELS.fetch(status)}:"
        group.each { |result| @out.puts "- #{result.domain}" }
        @out.puts
      end
    end
  end
end
