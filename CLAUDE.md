# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Docheck is a small Ruby gem and CLI that checks domain name availability. It takes a second-level name (for example `google`), appends each gTLD in `Docheck::Application::TLD`, and queries WHOIS for each one. The only runtime dependency is `whois` (pinned to `3.6.5`). The gemspec declares `required_ruby_version >= 1.9.2`.

## Commands

```sh
bundle install                                    # install dependencies
ruby -Itest test/docheck_test.rb                  # run all tests
ruby -Itest test/docheck_test.rb -n "/version/"   # run tests whose name matches a pattern
ruby bin/docheck -n <name>                        # run the CLI from source
rake build                                        # build the gem into pkg/
rake install                                      # build and install locally
rake release                                      # tag, push, and publish to RubyGems
```

- The Rakefile only loads `Bundler::GemHelper` tasks. It has no `test` task, so run tests with `ruby` directly.
- There is no linter configuration.
- Tests use `test/unit` with `shoulda` contexts (`context` / `should` blocks).
- Tests make real WHOIS network calls (for the name `railsmine`). They are slow and fail without network access. Several tests also shell out to `ruby bin/docheck` and compare its stdout exactly.

## Architecture

- `bin/docheck` loads `lib/docheck/command.rb`.
- `lib/docheck/command.rb` is the CLI. It runs `OptionParser` at load time (no wrapper class). It catches `InvalidOption` and `MissingArgument` and prints `Invalid option` / `Missing argument`. The tests assert these exact strings.
- `lib/docheck.rb` is the library entry point. It requires `whois`, the version, and the application.
- `lib/docheck/application.rb` holds all logic in `Docheck::Application`:
  - `#fetch` loops over `TLD`, calls `Whois.whois`, and sorts each domain into `@available_domains` or `@registered_domains`. It returns `[available, registered]`. It retries failed lookups up to 4 times, then skips the TLD. The `attempts` counter resets only after a skip, so successful lookups do not reset it.
  - `#print` calls `#fetch` and writes the result to stdout.
  - `#fetch` appends to the instance arrays, so a second call on the same instance duplicates results.
- `lib/docheck/version.rb` defines `Docheck::VERSION`. The gemspec reads it. Release commits bump it and use the version as the commit message (for example `v1.1.3`).
- The gemspec builds its file lists from `git ls-files`. Commit new files before you run `rake build`, or the gem will not include them.
