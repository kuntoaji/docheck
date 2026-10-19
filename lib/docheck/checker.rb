# frozen_string_literal: true

module Docheck
  # Checks a name against a list of TLDs, one RDAP lookup per TLD in parallel.
  class Checker
    # Generic TLDs open to public registration.
    DEFAULT_TLDS = %w[com net org info biz name pro mobi asia tel travel jobs aero cat coop museum].freeze

    # Upper bound in seconds for a whole #check call.
    DEADLINE = 10

    attr_reader :tlds

    def initialize(tlds: DEFAULT_TLDS, bootstrap: Bootstrap.default, http: HttpClient.new, deadline: DEADLINE)
      @tlds = tlds.map { |tld| tld.to_s.downcase.delete_prefix(".").freeze }.freeze
      @bootstrap = bootstrap
      @http = http
      @deadline = deadline
      freeze
    end

    # Returns one Result per TLD, in TLD order. Raises InvalidNameError when
    # +name+ is not a valid DNS label. Lookups still running at the deadline
    # get +:unknown+.
    def check(name)
      label = Name.normalize(name)
      threads = tlds.map { |tld| Thread.new { lookup("#{label}.#{tld}", tld) } }
      collect(threads, tlds.map { |tld| "#{label}.#{tld}" })
    end

    private

    def lookup(domain, tld)
      base_url = @bootstrap.base_url(tld)
      return :unsupported unless base_url

      @http.status("#{base_url}domain/#{domain}")
    rescue StandardError
      :unknown
    end

    def collect(threads, domains)
      ends_at = now + @deadline
      threads.zip(domains).map do |thread, domain|
        finished = thread.join([ends_at - now, 0].max)
        thread.kill unless finished
        Result.new(domain: domain, status: finished ? thread.value : :unknown)
      end
    end

    def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
