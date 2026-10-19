# frozen_string_literal: true

require_relative "lib/docheck/version"

Gem::Specification.new do |s|
  s.name        = "docheck"
  s.version     = Docheck::VERSION
  s.authors     = ["Kunto Aji Kristianto"]
  s.email       = "kuntoaji@kaklabs.com"
  s.homepage    = "https://github.com/kuntoaji/docheck"
  s.license     = "MIT"
  s.summary     = "Domain name availability checker"
  s.description = "Checks whether a domain name is available or registered across generic TLDs, using RDAP."

  s.required_ruby_version = ">= 3.2"

  s.files = Dir["lib/**/*.rb", "exe/*", "data/*.json", "README.rdoc", "LICENSE", "CHANGELOG.md"]
  s.bindir = "exe"
  s.executables = ["docheck"]
  s.require_paths = ["lib"]

  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]

  s.metadata = {
    "source_code_uri" => "https://github.com/kuntoaji/docheck",
    "changelog_uri" => "https://github.com/kuntoaji/docheck/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/kuntoaji/docheck/issues",
    "rubygems_mfa_required" => "true"
  }
end
