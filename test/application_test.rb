# frozen_string_literal: true

require_relative "test_helper"

class ApplicationTest < Minitest::Test
  include Fixtures

  def app
    checker = Docheck::Checker.new(tlds: %w[com net org], bootstrap: BOOTSTRAP,
                                   http: FakeHttp.new("acme.com" => :registered))
    Docheck::Application.new("acme", checker: checker)
  end

  def test_fetch_returns_available_and_registered
    application = app

    assert_equal [%w[acme.net], %w[acme.com]], application.fetch
    assert_equal %w[acme.net], application.available_domains
    assert_equal %w[acme.com], application.registered_domains
  end

  def test_fetch_twice_does_not_duplicate
    application = app
    application.fetch

    assert_equal [%w[acme.net], %w[acme.com]], application.fetch
  end

  def test_print
    out = StringIO.new

    assert app.print(out)
    assert_equal "Available Domains:\n- acme.net\n\nRegistered Domains:\n- acme.com\n", out.string
  end
end
