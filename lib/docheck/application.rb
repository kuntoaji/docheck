# frozen_string_literal: true

module Docheck
  # The 1.x API, kept for compatibility. New code should use Checker.
  class Application
    attr_reader :available_domains, :registered_domains

    def initialize(base_name, checker: Checker.new)
      @base_name = base_name
      @checker = checker
      @available_domains = []
      @registered_domains = []
    end

    # Returns [available_domains, registered_domains]. Each call replaces the
    # previous result. Raises InvalidNameError for an invalid name.
    def fetch
      results = @checker.check(@base_name)
      @available_domains = results.select(&:available?).map(&:domain)
      @registered_domains = results.select(&:registered?).map(&:domain)
      [@available_domains, @registered_domains]
    end

    # Prints the fetch result to +out+ and returns true.
    def print(out = $stdout) # rubocop:disable Naming/PredicateMethod -- 1.x public API name
      available, registered = fetch
      out.puts "Available Domains:"
      available.each { |domain| out.puts "- #{domain}" }
      out.puts
      out.puts "Registered Domains:"
      registered.each { |domain| out.puts "- #{domain}" }
      true
    end
  end
end
