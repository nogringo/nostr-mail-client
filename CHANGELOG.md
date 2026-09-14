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

### Fixed

- Show the body of an email in the inbox and scheduled lists as it reads,
  instead of its formatting marks, without the quoted reply or the signature.
- Send the plain-text version of an email as readable text, for the apps that
  show that version, instead of formatting marks.

## [0.15.0]

### Added

- Use several accounts on the same device: add them from the account menu and
  switch in one tap, without signing out.
- Guide Android FOSS users to install a UnifiedPush distributor when none is available.
- Enable push notifications on web.
- Confirm before leaving the hosting or address settings with unsaved changes.
- Add background presets with light and dark variants, including
  animated waves and image backgrounds.
- Delete your account from the settings: your relays are asked to erase your
  messages.
- Show in the hosting settings when the device itself has no network, so it can
  be told apart from your relays being down.
- Tap the sender or a recipient of an email to open their card: write to them,
  open or add their contact, or copy their address. It replaces the add to
  contacts button in the email header.
- Find your relay list after sign-in when it is missing: look it up on a relay,
  a Nostr address, or an nprofile, or create a new one.
- Turn notifications on or off for each account.

### Changed

- Reorganize the settings into their own pages, with related settings grouped
  into cards.
- Improve the macOS DMG installer window with a custom background and icon
  layout for both app variants.
- Publish your profile and relay list to the relays that index them, so another
  app or a fresh device can find your account from your key alone.
- Publish your message relay and media server lists to your own relays only,
  since nothing reads them before your relay list has been found.
- Reconnect to your relays as soon as the device regains a network, and when the
  app returns to the foreground, instead of waiting out the retry delay.
- Show an email's source from the email actions, instead of a setting.
- Open mailboxes faster, and keep the inbox responsive while new messages sync.
- Remove the settings button from the mobile app bar. Settings stay in the
  drawer.

### Fixed

- Keep the container colors of a theme built from a wallpaper, which made cards
  and grouped rows blend into the background.
- Keep full-screen pages clear of the window controls on desktop.
- Restore window resizing from the window edges on macOS.
- Allow pasting into To, Cc, and Bcc recipient fields on Android.
- Allow adding and downloading email attachments on macOS.
- Keep the macOS app running when the last window is closed, matching native
  macOS behavior.
- Leave the relay setup screen on its own once the network is back, instead of
  waiting for a tap on Try again.
- Report that no relay could be reached right away when the device has no
  network, instead of waiting for the search to time out.
- Stop reporting a failure when saving your profile, which was in fact saved and
  published every time.
- Show a readable name for a Nostr sender without a profile, instead of their
  full `npub@nostr` address, in the email header and the inbox.
- Show the name and picture of people whose profile is only on their own relays.
- Read each list row as one item, and announce buttons as buttons, with a screen
  reader.
- Stop clipping recipient chips in compose at large text sizes.
- Keep attachment filenames on one line.

## [0.14.2]

### Fixed

- Fix macOS sign-in and account storage in signed release builds.

## [0.14.1]

### Fixed

- Fix Android release APK startup crash caused by the local notification icon
  resource being stripped during optimization.

## [0.14.0]

### Added

- Nmail is now available on macOS.
- Schedule emails for future delivery: pick a send time from compose and confirm with Send, then view, edit, or cancel queued emails in a new Scheduled mailbox.
- Push notifications.

### Changed

- Improve mobile email list hierarchy by showing the sender first, with a lighter treatment, followed by the subject and body preview.
- Remove the desktop account menu toast after copying the user's npub, since the menu closing already confirms the action.
- Show all sent-email recipients in email list tiles.

### Fixed

- Allow selecting a recipient from the autocomplete suggestions with a mouse click when composing.
- Auto-select a bridge sender when selecting an SMTP recipient from autocomplete.
- Allow returning to the selected mailbox from Compose on desktop.
- Make the compose Cc/From expander easier to discover on desktop.
- Use NDK's NIP-05 resolver for address book Nostr identifiers.
- Keep pending signer requests above Android's three-button navigation bar.

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
