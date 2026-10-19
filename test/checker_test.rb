# frozen_string_literal: true

require_relative "test_helper"

class CheckerTest < Minitest::Test
  include Fixtures

  def checker(http, tlds: %w[com net org], deadline: 5)
    Docheck::Checker.new(tlds: tlds, bootstrap: BOOTSTRAP, http: http, deadline: deadline)
  end

  def test_returns_one_result_per_tld_in_order
    results = checker(FakeHttp.new("acme.com" => :registered)).check("Acme")

    assert_equal [
      Docheck::Result.new(domain: "acme.com", status: :registered),
      Docheck::Result.new(domain: "acme.net", status: :available),
      Docheck::Result.new(domain: "acme.org", status: :unsupported)
    ], results
  end

  def test_queries_the_rdap_domain_path
    http = FakeHttp.new
    checker(http, tlds: %w[com net]).check("acme")
    urls = Array.new(http.urls.size) { http.urls.pop }

    assert_equal %w[https://rdap.example.com/domain/acme.com https://rdap.example.net/domain/acme.net], urls.sort
  end

  def test_raises_for_invalid_name_before_any_lookup
    http = FakeHttp.new

    assert_raises(Docheck::InvalidNameError) { checker(http).check("a_b") }
    assert_empty http.urls
  end

  def test_maps_client_exceptions_to_unknown
    results = checker(FakeHttp.new("acme.com" => -> { raise "boom" })).check("acme")

    assert_equal :unknown, results.first.status
  end

  def test_marks_lookups_past_the_deadline_unknown
    http = FakeHttp.new("acme.com" => lambda {
      sleep 5
      :registered
    })
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    results = checker(http, tlds: %w[com net], deadline: 0.2).check("acme")

    assert_equal %i[unknown available], results.map(&:status)
    assert_operator Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, :<, 2
  end

  def test_normalizes_tlds
    assert_equal %w[com net], Docheck::Checker.new(tlds: [".COM", :net]).tlds
  end

  def test_result_rejects_unknown_status
    assert_raises(ArgumentError) { Docheck::Result.new(domain: "a.com", status: :maybe) }
  end
end
