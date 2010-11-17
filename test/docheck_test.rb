require File.expand_path('../helper.rb', __FILE__)

class TestDocheck < Test::Unit::TestCase
  context "Docheck gem" do
    should "require Whois" do
      assert defined?(Whois)
    end
  end

  context "Docheck command" do
    setup do
      @docheck_bin = File.expand_path("../../bin/docheck", __FILE__)
    end

    should "shows version" do
      assert_equal "Docheck #{Docheck::VERSION}\n", `ruby #{@docheck_bin} -v`
      assert_equal "Docheck #{Docheck::VERSION}\n", `ruby #{@docheck_bin} --version`
    end

    should "executes domain name checker correctly" do
      assert `ruby #{@docheck_bin} -n railsmine`
      assert `ruby #{@docheck_bin} --name railsmine`
    end

    should "prints 'Invalid option'" do
      assert_equal "Invalid option\n", `ruby #{@docheck_bin} -f`
      assert_equal "Invalid option\n", `ruby #{@docheck_bin} --foo`
      assert_equal "Invalid option\n", `ruby #{@docheck_bin} --foo bar`
    end

    should "prints 'Missing argument'" do
      assert_equal "Missing argument\n", `ruby #{@docheck_bin} -n`
      assert_equal "Missing argument\n", `ruby #{@docheck_bin} --name`
    end
  end

  context "A Docheck instance" do
    setup do
      @docheck = Docheck::Application.new('railsmine')
    end

    should "responds to all its public instance method" do
      assert @docheck.respond_to?(:fetch)
      assert @docheck.respond_to?(:print)
      assert @docheck.respond_to?(:available_domains)
      assert @docheck.respond_to?(:registered_domains)
    end

    should "returns all availability and registered domain" do
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

    should "runs #print successfully" do
      assert @docheck.print 
    end
  end
end

