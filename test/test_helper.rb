# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../lib/docheck"
require_relative "../lib/docheck/cli"

# An HTTP client that returns a fixed status per domain, with no network.
class FakeHttp
  attr_reader :urls

  def initialize(statuses = {}, default = :available)
    @statuses = statuses
    @default = default
    @urls = Thread::Queue.new
  end

  def status(url)
    @urls << url
    domain = url.split("/").last
    result = @statuses.fetch(domain, @default)
    result.respond_to?(:call) ? result.call : result
  end
end

module Fixtures
  BOOTSTRAP = Docheck::Bootstrap.new("com" => "https://rdap.example.com/", "net" => "https://rdap.example.net")

  def http_response(klass, code, location: nil)
    response = klass.new("1.1", code.to_s, "")
    response["location"] = location if location
    response
  end
end
