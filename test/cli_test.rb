# frozen_string_literal: true

require_relative "test_helper"

class CLITest < Minitest::Test
  include Fixtures

  def run_cli(*argv)
    out = StringIO.new
    err = StringIO.new
    checker = Docheck::Checker.new(tlds: %w[com net org], bootstrap: BOOTSTRAP,
                                   http: FakeHttp.new("acme.com" => :registered, "acme.net" => :unknown))
    status = Docheck::CLI.new(argv, out: out, err: err, checker: checker).run
    [status, out.string, err.string]
  end

  def test_prints_results_grouped_by_status
    status, out, err = run_cli("-n", "acme")

    assert_equal 0, status
    assert_equal <<~TEXT, out
      Registered:
      - acme.com

      Unknown (lookup failed):
      - acme.net

      Unsupported (no RDAP server):
      - acme.org

    TEXT
    assert_empty err
  end

  def test_long_name_option
    assert_equal 0, run_cli("--name", "acme").first
  end

  def test_version
    %w[-v --version].each do |flag|
      assert_equal [0, "docheck #{Docheck::VERSION}\n", ""], run_cli(flag)
    end
  end

  def test_help
    status, out, = run_cli("-h")

    assert_equal 0, status
    assert_includes out, "Usage: docheck -n NAME"
  end

  def test_usage_errors_exit_64_on_stderr
    [[], %w[-n], %w[--foo], %w[-n a_b]].each do |argv|
      status, out, err = run_cli(*argv)

      assert_equal 64, status, argv.inspect
      assert_empty out
      assert_match(/\Adocheck: .+\nUsage:/, err)
    end
  end
end
