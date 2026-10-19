# frozen_string_literal: true

require "json"

module Docheck
  # Maps each TLD to its RDAP base URL, using the IANA bootstrap file format
  # (RFC 9224). The gem bundles a snapshot in data/rdap_dns.json so that a
  # lookup needs no extra network call. Refresh it with `rake rdap:update`.
  class Bootstrap
    DEFAULT_PATH = File.expand_path("../../data/rdap_dns.json", __dir__)

    def self.default
      @default ||= load_file(DEFAULT_PATH)
    end

    def self.load_file(path)
      parse(File.read(path))
    end

    def self.parse(json)
      services = JSON.parse(json).fetch("services")
      new(services.each_with_object({}) do |(tlds, urls), map|
        url = urls.find { |u| u.start_with?("https://") }
        tlds.each { |tld| map[tld.downcase] = url } if url
      end)
    rescue JSON::ParserError, KeyError, TypeError, NoMethodError => e
      raise BootstrapError, "invalid RDAP bootstrap data: #{e.message}"
    end

    def initialize(base_urls)
      @base_urls = base_urls.to_h do |tld, url|
        raise BootstrapError, "RDAP base URL for #{tld} must use https: #{url}" unless url.start_with?("https://")

        [tld.downcase.freeze, (url.end_with?("/") ? url : "#{url}/").freeze]
      end.freeze
      freeze
    end

    # Returns the RDAP base URL for +tld+ (ending in "/"), or nil.
    def base_url(tld)
      @base_urls[tld.to_s.downcase]
    end
  end
end
