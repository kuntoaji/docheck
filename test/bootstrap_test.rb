# frozen_string_literal: true

require_relative "test_helper"

class BootstrapTest < Minitest::Test
  def test_bundled_snapshot_covers_default_tlds
    Docheck::Checker::DEFAULT_TLDS.each do |tld|
      assert_match %r{\Ahttps://.+/\z}, Docheck::Bootstrap.default.base_url(tld), tld
    end
  end

  SAMPLE = <<~JSON
    {"services": [[["a", "B"], ["http://plain.example/", "https://rdap.example/a"]], [["c"], ["http://only.example/"]]]}
  JSON

  def test_parse_maps_each_tld_to_its_https_url
    bootstrap = Docheck::Bootstrap.parse(SAMPLE)

    assert_equal "https://rdap.example/a/", bootstrap.base_url("a")
    assert_equal "https://rdap.example/a/", bootstrap.base_url("b")
  end

  def test_parse_skips_tlds_without_https_url
    bootstrap = Docheck::Bootstrap.parse(SAMPLE)

    assert_nil bootstrap.base_url("c")
    assert_nil bootstrap.base_url("zz")
  end

  def test_parse_rejects_malformed_data
    ["not json", "{}", '{"services": 1}'].each do |json|
      assert_raises(Docheck::BootstrapError, json) { Docheck::Bootstrap.parse(json) }
    end
  end

  def test_rejects_non_https_base_url
    assert_raises(Docheck::BootstrapError) { Docheck::Bootstrap.new("com" => "http://rdap.example/") }
  end

  def test_is_frozen
    assert_predicate Docheck::Bootstrap.default, :frozen?
  end
end
