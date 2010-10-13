# Domain name availability checker
#
# Author::    Kunto Aji Kristianto  (mailto:kunto.aji.kr@gmail.com)
# Copyright:: Copyright (c) 2010 Kunto Aji Kristianto
# License::   Distributes under MIT license

require 'whois'

class Docheck

  # DNS name of the generic top-level domain
  TLD = %w{aero asia biz cat com coop edu gov info
  int jobs mil mobi museum name net org pro tel travel}

  # Public instance method to return available domains or
  # registered domains
  attr_reader :available_domains, :registered_domains

  # base_name is sld (Second Level Domain) and
  # converted to lower case.
  def initialize(base_name)
    @base_name = base_name.downcase
    @available_domains = []
    @registered_domains = []
  end

  # Print the result to STDOUT.
  # Used by docheck executable.
  def print
    result = fetch
    
    puts "\nDocheck Result\n"
    puts "--------------\n"
    puts "Available Domains:"
    result.first.map{|domain_name| puts "- #{domain_name}"}
    puts "\n"
    puts "Registered Domains:"
    result.last.map{|domain_name| puts "- #{domain_name}"}
  end

  # Responsible to check domain's availability
  # and return the result as array. 
  #
  # The first element of array will return all
  # available domains as array.
  #
  # The last element of array will return all
  # registered domains as array.
  def fetch
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
        next
      rescue
        next
      end
    end

    return [@available_domains, @registered_domains]
  end
end
