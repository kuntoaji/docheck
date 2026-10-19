# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Docheck is a Ruby gem and CLI that checks domain name availability with RDAP. It takes a second-level name (for example `google`), appends each TLD in `Docheck::Checker::DEFAULT_TLDS`, and sends one HTTPS request per domain to the registry's RDAP server. It has no runtime dependencies. It requires Ruby >= 3.2 and is developed on Ruby 4.0.7 (`.ruby-version`).

kak_api (`~/Workspace/kak_api`) uses this gem for `GET /tools/domain-availability`, which the Domain Availability Checker page in kaktools (`~/Workspace/kaktools`) calls. If you change the `Checker` or `Result` API, update that route and its spec.

## Commands

```sh
bundle install
bundle exec rake                                   # tests (ruby -w) and RuboCop
bundle exec rake test                              # tests only
bundle exec ruby -Itest test/checker_test.rb       # one test file
bundle exec ruby -Itest test/checker_test.rb -n "/deadline/"   # tests matching a pattern
bundle exec rubocop -a                             # autocorrect lint offenses
bundle exec rake rdap:update                       # refresh data/rdap_dns.json from IANA
ruby -Ilib exe/docheck -n <name>                   # run the CLI from source (live network)
gem build docheck.gemspec
```

- Tests make no network calls. They inject `FakeHttp` (`test/test_helper.rb`) into `Checker`, or a fake `requester` lambda into `HttpClient`. Keep it that way.
- CI (`.github/workflows/ci.yml`) runs `bundle exec rake` on Ruby 3.2, 3.3, 3.4, and 4.0. Do not use syntax newer than Ruby 3.2.

## Architecture

- `Checker#check(name)` validates the name with `Name.normalize`, starts one thread per TLD, and joins them against one overall `deadline`. A thread still running at the deadline is killed, and its result is `:unknown`. The result is one `Result` per TLD, in TLD order.
- `Result` is a `Data` with `domain` and `status`. The status is one of `:available` (404), `:registered` (200), `:unknown` (any other response, timeout, or network error), or `:unsupported` (the TLD has no RDAP server).
- `Bootstrap` maps TLD to RDAP base URL from `data/rdap_dns.json`, a bundled snapshot of https://data.iana.org/rdap/dns.json. Loading it needs no network, which matters because kak_api freezes everything in production. It keeps only `https://` URLs.
- `HttpClient` sends `HEAD`, not `GET`. Verisign (com, net, name) ends a `GET` 404 body by closing TLS without `close_notify`, and Ruby's OpenSSL 3 raises `SSLError` on that. It retries once on a timeout or 5xx, and follows at most one redirect, only to `https://`.
- `Name::LABEL` allows only one LDH label. The name goes into the RDAP URL path, so this validation also blocks path injection. Do not loosen it without a replacement check.
- `CLI#run` returns the exit status (0 for success, 64 for a usage error) and writes to injected `out`/`err` streams. `exe/docheck` only calls it.
- `Application` is the 1.x API, kept as a wrapper over `Checker` for compatibility.
- The gemspec lists files with `Dir` globs, so it includes `data/rdap_dns.json` and `CHANGELOG.md`. Add new top-level directories to that list.

## Releases

Bump `lib/docheck/version.rb`, run `rake rdap:update`, update `CHANGELOG.md`, and commit with the version as the message (for example `v2.0.0`). 2.0.0 is not yet published to RubyGems. Publish only when the user asks.

## Git

- Always commit directly to `master` in this repository. Do not create feature branches, even when global instructions say to branch first.
