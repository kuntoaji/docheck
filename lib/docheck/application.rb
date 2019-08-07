module Docheck
  class Application

    # DNS name of the generic top-level domain
    # http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains
    TLD = %w[aero asia biz cat com coop edu gov info
    int jobs mil mobi museum name net org pro tel travel]

    attr_reader :available_domains, :registered_domains

    # base_name is sld (Second Level Domain) and
    # converted to lower case.
    def initialize(base_name)
      @base_name = base_name.to_s.downcase
      @available_domains = []
      @registered_domains = []
    end

    # Print the fetch result.
    def print
      result = fetch

      puts "\nDocheck Result\n"
      puts "--------------\n"
      puts "Available Domains:"
      result.first.map{|domain_name| puts "- #{domain_name}"}
      puts "\n"
      puts "Registered Domains:"
      result.last.map{|domain_name| puts "- #{domain_name}"}

      true
    end

    # Check domain name availability
    # and return the result as array.
    #
    # The first element of array will return all
    # available domains as array.
    #
    # The last element of array will return all
    # registered domains as array.
    def fetch
      attempts = 0
      TLD.each do |tld|
        domain_name = "#{@base_name}.#{tld}"
        begin
          whois_domain = Whois.whois(domain_name)

          if whois_domain.available?
            @available_domains << domain_name
          elsif whois_domain.registered?
            @registered_domains << domain_name
          end
        rescue Timeout::Error
          if attempts <= 3
            attempts += 1
            retry
          else
            attempts = 0
            next
          end
        rescue
          if attempts <= 3
            attempts += 1
            retry
          else
            attempts = 0
            next
          end
        end
      end

      return [@available_domains, @registered_domains]
    end
  end
end
