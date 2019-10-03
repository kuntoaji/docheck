# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "docheck/version"

Gem::Specification.new do |s|
  s.name        = "docheck"
  s.version     = Docheck::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Kunto Aji Kristianto"
  s.email       = 'kuntoaji@kaklabs.com'
  s.homepage    = "http://github.com/kuntoaji/docheck"
  s.license     = 'MIT'
  s.summary     = 'Domain name availability checker'
  s.description = <<-EOF
    Domain name availability checker.
  EOF

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ['--main', 'README.rdoc']
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE']

  s.required_ruby_version = '>= 1.9.2'
  s.add_dependency('whois', '3.6.5')
  s.add_development_dependency('shoulda', '~> 3.6.0')
end
