# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "rubocop/rake_task"

Minitest::TestTask.create do |t|
  t.warning = true
end

RuboCop::RakeTask.new

namespace :rdap do
  desc "Refresh data/rdap_dns.json from the IANA RDAP bootstrap registry"
  task :update do
    require "net/http"
    require_relative "lib/docheck"

    body = Net::HTTP.get(URI("https://data.iana.org/rdap/dns.json"))
    Docheck::Bootstrap.parse(body) # raises on malformed data
    File.write(Docheck::Bootstrap::DEFAULT_PATH, body)
    puts "Updated #{Docheck::Bootstrap::DEFAULT_PATH}"
  end
end

task default: %i[test rubocop]
