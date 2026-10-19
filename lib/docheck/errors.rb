# frozen_string_literal: true

module Docheck
  # Base class for all Docheck errors.
  class Error < StandardError; end

  # Raised when a name is not a valid DNS label.
  class InvalidNameError < Error; end

  # Raised when the RDAP bootstrap data is malformed.
  class BootstrapError < Error; end
end
