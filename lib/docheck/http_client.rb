# frozen_string_literal: true

require "net/http"
require "openssl"
require "uri"

module Docheck
  # Queries one RDAP domain URL and maps the HTTP response to a status.
  #
  # It sends HEAD, not GET (RFC 7480 section 4.1). The status code is all it
  # needs, and some registries (Verisign) end a GET body by closing TLS without
  # close_notify, which OpenSSL 3 reports as an error.
  class HttpClient
    TIMEOUT = 3
    MAX_REDIRECTS = 1
    RETRIES = 1

    # +requester+ takes a URI and returns a Net::HTTPResponse. Tests pass a
    # fake one; the default performs a real HTTPS HEAD request.
    def initialize(timeout: TIMEOUT, requester: nil)
      @timeout = timeout
      @requester = requester || method(:head)
    end

    # Returns +:registered+, +:available+, or +:unknown+ for +url+.
    def status(url)
      fetch_status(URI(url), MAX_REDIRECTS, RETRIES)
    rescue URI::Error
      :unknown
    end

    private

    NETWORK_ERRORS = [IOError, SystemCallError, SocketError, OpenSSL::SSL::SSLError, Net::ProtocolError].freeze
    private_constant :NETWORK_ERRORS

    def fetch_status(uri, redirects_left, retries_left)
      return :unknown unless uri.is_a?(URI::HTTPS)

      response = @requester.call(uri)
      case response
      when Net::HTTPOK then :registered
      when Net::HTTPNotFound then :available
      when Net::HTTPRedirection then follow(uri, response["location"], redirects_left, retries_left)
      when Net::HTTPServerError then retry_once(uri, redirects_left, retries_left)
      else :unknown
      end
    rescue Timeout::Error
      retry_once(uri, redirects_left, retries_left)
    rescue *NETWORK_ERRORS
      :unknown
    end

    def retry_once(uri, redirects_left, retries_left)
      return :unknown unless retries_left.positive?

      fetch_status(uri, redirects_left, retries_left - 1)
    end

    def follow(uri, location, redirects_left, retries_left)
      return :unknown if redirects_left.zero? || location.nil?

      fetch_status(uri.merge(location), redirects_left - 1, retries_left)
    end

    def head(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                          open_timeout: @timeout, read_timeout: @timeout,
                                          ssl_timeout: @timeout) do |http|
        request = Net::HTTP::Head.new(uri)
        request["Accept"] = "application/rdap+json"
        request["User-Agent"] = "docheck/#{VERSION} (+https://github.com/kuntoaji/docheck)"
        http.request(request)
      end
    end
  end
end
