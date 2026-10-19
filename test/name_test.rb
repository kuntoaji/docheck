# frozen_string_literal: true

require_relative "test_helper"

class NameTest < Minitest::Test
  def test_normalizes_case_and_whitespace
    assert_equal "google", Docheck::Name.normalize("  GooGle \n")
  end

  def test_accepts_valid_labels
    %w[a 9 a-b xn--bcher-kva].push("a" * 63).each do |label|
      assert_equal label, Docheck::Name.normalize(label)
    end
  end

  def test_rejects_invalid_labels
    ["", " ", "-a", "a-", "a_b", "a.b", "a b", "ü", "a/../b", "a" * 64, nil].each do |label|
      assert_raises(Docheck::InvalidNameError, label.inspect) { Docheck::Name.normalize(label) }
    end
  end
end
