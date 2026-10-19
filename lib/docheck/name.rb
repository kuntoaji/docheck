# frozen_string_literal: true

module Docheck
  # Validates the second-level name that Docheck appends each TLD to.
  module Name
    # One LDH (letter, digit, hyphen) label of 1 to 63 characters that does
    # not start or end with a hyphen. IDNs must be passed in punycode (xn--).
    LABEL = /\A[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/

    # Returns +name+ stripped and downcased, or raises InvalidNameError.
    def self.normalize(name)
      label = name.to_s.strip.downcase
      return label if LABEL.match?(label)

      raise InvalidNameError,
            "#{name.to_s.inspect} is not a valid domain name label " \
            "(1-63 letters, digits, or hyphens, no leading or trailing hyphen)"
    end
  end
end
