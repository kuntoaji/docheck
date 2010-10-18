require File.expand_path('../helper.rb', __FILE__)

class TestDocheck < Test::Unit::TestCase
  context "Docheck gem" do
    should "require Whois" do
      assert defined?(Whois)
    end
  end

  context "A Docheck instance" do
    setup do
      @docheck = Docheck::Application.new('railsmine')
    end

    should "respond to all its public instance method" do
      assert @docheck.respond_to?(:fetch)
      assert @docheck.respond_to?(:print)
      assert @docheck.respond_to?(:available_domains)
      assert @docheck.respond_to?(:registered_domains)
    end

    should "return all availability and registered domain" do
      result = @docheck.fetch
      assert result.is_a?(Array)
      assert result.first.is_a?(Array)
      assert @docheck.available_domains.is_a?(Array)
      assert_equal result.first, @docheck.available_domains
      assert result.last.is_a?(Array)
      assert @docheck.registered_domains.is_a?(Array)
      assert_equal result.last, @docheck.registered_domains
      assert_not_nil result
    end

    should "run #print successfully" do
      assert @docheck.print 
    end
  end
end

