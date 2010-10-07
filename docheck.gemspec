Gem::Specification.new do |spec|
  spec.authors = 'Kunto Aji Kristianto'
  spec.add_dependency('whois', '~> 1.3.8')
  spec.description = <<-EOF
    Docheck is a tool to check domain name availability.
    By default, It will return all available and registered domains.
  EOF
  spec.email = 'kunto.aji.kr@gmail.com'
  spec.executables << 'docheck'
  spec.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'VERSION']
  spec.files = ['.gitignore', 'docheck.gemspec', 'LICENSE',
    'README.rdoc', 'VERSION', 'bin/docheck', 'lib/docheck.rb',
    'test/docheck_test.rb', 'test/helper.rb']
  spec.has_rdoc = true
  spec.homepage = 'http://github.com/kuntoaji/docheck'
  spec.name = 'docheck'
  spec.rdoc_options = ['--main', 'README.rdoc']
  spec.required_ruby_version = '>= 1.8.7'
  spec.requirements << 'ruby-whois, v1.3.8 or greater'
  spec.summary = 'Domain name availability checker.'
  spec.test_files = ['test/docheck_test.rb', 'test/helper.rb'] 
  spec.version = '1.0.0'
end
