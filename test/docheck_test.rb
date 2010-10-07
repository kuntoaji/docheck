require File.expand_path('../helper.rb', __FILE__)

class TestDocheck < Test::Unit::TestCase
  context "A Docheck instance" do
    setup do
      @docheck = Docheck.new('railsmine')
    end

    should "return all availability and registered domain" do
      result = @docheck.fetch
      assert result.is_a?(Array)
      assert result.first.is_a?(Array)
      assert result.last.is_a?(Array)
      assert_not_nil result
    end

    should "run #print successfully" do
      assert @docheck.print 
    end
  end
end

