# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

When preparing a release, write the notes for the new version under a
`## [x.y.z]` heading that matches the version in `pubspec.yaml`. The release
workflow extracts that section automatically and appends GitHub's generated
list of merged pull requests below it.

Releases prior to 0.13.0 are listed on the
[GitHub releases page](https://github.com/nogringo/nostr-mail-client/releases).

## [Unreleased]

### Added

- Schedule an email for future delivery from the compose screen: a clock button next to Send lets you pick a date and time, and the email is sent later by the Scheduler DVM.
- A Scheduled mailbox that lists emails queued for future delivery and lets you cancel a scheduled send before it goes out. Reachable from the sidebar on desktop and the navigation drawer on mobile.

### Fixed

- Allow selecting a recipient from the autocomplete suggestions with a mouse click when composing.

## [0.13.1]

### Fixed

- Restore NIP-55 signer app login support for apps like Amber, Aegis, and Primal.
- Stop repeatedly prompting signer apps to sign contacts after a contact is created.

## [0.13.0]

### Added

- Address book contacts.

### Changed

- Use the primary container color for the default background.

### Fixed

- Make email avatar colors deterministic.
