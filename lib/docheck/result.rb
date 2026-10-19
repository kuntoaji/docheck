# frozen_string_literal: true

module Docheck
  # The availability of one domain name.
  #
  # +status+ is one of:
  # - +:available+: the registry has no record of the domain
  # - +:registered+: the registry has a record of the domain
  # - +:unknown+: the lookup failed (timeout, rate limit, or server error)
  # - +:unsupported+: the TLD has no RDAP server in the bootstrap data
  Result = Data.define(:domain, :status) do
    def initialize(domain:, status:)
      raise ArgumentError, "unknown status: #{status.inspect}" unless Result::STATUSES.include?(status)

      super
    end

    def available? = status == :available
    def registered? = status == :registered
  end

  Result::STATUSES = %i[available registered unknown unsupported].freeze
end
