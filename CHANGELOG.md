# Changelog

## 2.0.0 - Unreleased

### Breaking changes

- Require Ruby 3.2 or later. Tested on Ruby 3.2 to 4.0.
- Look up domains with RDAP instead of WHOIS. The `whois` dependency is gone.
- Drop `edu`, `gov`, `int`, and `mil` from the default TLDs. Only institutions can register them.
- Raise `Docheck::InvalidNameError` for a name that is not a single DNS label.
- The `docheck` command prints errors to stderr and exits with status 64 on a usage error. It also lists domains whose lookup failed or whose TLD has no RDAP server.
- `Docheck::Application#print` no longer prints the "Docheck Result" header.

### Added

- `Docheck.check` and `Docheck::Checker`, which return `Docheck::Result` objects with a status of `:available`, `:registered`, `:unknown`, or `:unsupported`.
- Parallel lookups with an overall deadline.
- `rake rdap:update` to refresh the bundled IANA RDAP bootstrap file.

### Fixed

- Calling `Docheck::Application#fetch` twice no longer duplicates results.
- A failed lookup no longer uses up the retry budget of the TLDs after it.
