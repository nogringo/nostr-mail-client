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

- Schedule emails for future delivery: pick a send time from compose and confirm with Send, then view, edit, or cancel queued emails in a new Scheduled mailbox.

### Changed

- Improve mobile email list hierarchy by showing the sender first, with a lighter treatment, followed by the subject and body preview.

### Fixed

- Allow selecting a recipient from the autocomplete suggestions with a mouse click when composing.
- Auto-select a bridge sender when selecting an SMTP recipient from autocomplete.
- Allow returning to the selected mailbox from Compose on desktop.
- Make the compose Cc/From expander easier to discover on desktop.

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
