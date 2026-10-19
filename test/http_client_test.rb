# frozen_string_literal: true

require_relative "test_helper"

class HttpClientTest < Minitest::Test
  include Fixtures

  URL = "https://rdap.example/domain/x.com"

  def client(*responses)
    calls = []
    requester = lambda do |uri|
      calls << uri.to_s
      response = responses.shift
      response.is_a?(Exception) || response.is_a?(Class) ? raise(response) : response
    end
    [Docheck::HttpClient.new(requester: requester), calls]
  end

  def test_maps_200_to_registered
    http, = client(http_response(Net::HTTPOK, 200))

    assert_equal :registered, http.status(URL)
  end

  def test_maps_404_to_available
    http, = client(http_response(Net::HTTPNotFound, 404))

    assert_equal :available, http.status(URL)
  end

  def test_maps_rate_limit_and_client_errors_to_unknown
    [[Net::HTTPTooManyRequests, 429], [Net::HTTPBadRequest, 400], [Net::HTTPForbidden, 403]].each do |klass, code|
      http, calls = client(http_response(klass, code))

      assert_equal :unknown, http.status(URL), code
      assert_equal 1, calls.size
    end
  end

  def test_retries_once_on_server_error
    http, calls = client(http_response(Net::HTTPServiceUnavailable, 503), http_response(Net::HTTPOK, 200))

    assert_equal :registered, http.status(URL)
    assert_equal 2, calls.size
  end

  def test_gives_up_after_one_retry
    http, calls = client(http_response(Net::HTTPInternalServerError, 500), http_response(Net::HTTPBadGateway, 502))

    assert_equal :unknown, http.status(URL)
    assert_equal 2, calls.size
  end

  def test_retries_once_on_timeout
    http, calls = client(Net::OpenTimeout, http_response(Net::HTTPNotFound, 404))

    assert_equal :available, http.status(URL)
    assert_equal 2, calls.size
  end

  def test_maps_network_errors_to_unknown
    [Errno::ECONNREFUSED, SocketError, OpenSSL::SSL::SSLError].each do |error|
      http, = client(error)

      assert_equal :unknown, http.status(URL), error.name
    end
  end

  def test_follows_one_https_redirect
    redirect = http_response(Net::HTTPFound, 302, location: "/rdap/domain/x.com")
    http, calls = client(redirect, http_response(Net::HTTPOK, 200))

    assert_equal :registered, http.status(URL)
    assert_equal [URL, "https://rdap.example/rdap/domain/x.com"], calls
  end

  def test_does_not_follow_a_second_redirect
    redirect = http_response(Net::HTTPFound, 302, location: "https://a.example/x")
    http, calls = client(redirect, redirect)

    assert_equal :unknown, http.status(URL)
    assert_equal 2, calls.size
  end

  def test_refuses_redirect_to_plain_http
    http, calls = client(http_response(Net::HTTPMovedPermanently, 301, location: "http://rdap.example/x"))

    assert_equal :unknown, http.status(URL)
    assert_equal 1, calls.size
  end

  def test_refuses_non_https_url
    http, calls = client

    assert_equal :unknown, http.status("http://rdap.example/domain/x.com")
    assert_empty calls
  end
end
