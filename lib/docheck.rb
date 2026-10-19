# frozen_string_literal: true

require_relative "docheck/version"
require_relative "docheck/errors"
require_relative "docheck/name"
require_relative "docheck/result"
require_relative "docheck/bootstrap"
require_relative "docheck/http_client"
require_relative "docheck/checker"
require_relative "docheck/application"

# Domain name availability checker built on RDAP.
module Docheck
  # Checks +name+ against the default TLDs. See Checker#check.
  def self.check(name)
    Checker.new.check(name)
  end
end
