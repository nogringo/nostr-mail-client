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

- Receive the emails of new senders in Requests, and those of blocked senders
  in Spam. Accept or block a sender from Requests, or block one from any
  email. A verdict moves all the emails of that sender at once, and follows
  you on all your devices. The inbox shows how many senders are waiting.
- Empty the spam in one tap from the banner at the top of Spam.
- Stay silent for an email routed to Spam, and notify a request only when its
  sender has nothing else waiting in Requests.
- Browse the themes shared by other Nostr users from the appearance settings,
  search them by name, filter them by color or background image, and apply
  one in a tap. Each theme has its own page and a link to share it.
- Share your current look as a community theme, marked NSFW if needed. The
  image of a sensitive theme stays hidden behind a warning until you show it.
- Mute the author of a community theme to hide all of their themes.
- Manage your private relays, which store private data such as drafts, from
  the hosting settings.
- Confirm before logging out, with what leaves the device and what stays on
  your relays.
- Ask for the device lock before copying the sync code, on Android, iOS,
  macOS, and Windows.
- Unlock the debug tools in a release build by tapping the Nmail tile in About
  seven times, and hide them again from their page.
- Install Nmail on Windows, with an installer or a zip from the releases page.

### Changed

- Move the emails already in your inbox to Requests until you accept their
  sender. Accept all, in Requests, brings them back to the inbox at once.
- Reply from the address the email reached: an email received on one of your
  identities is answered from that identity.
- Write to an email address from the address the account menu copies, your
  first identity or your first bridge, instead of a guess based on your past
  emails. Reorder your identities in the settings to change it.

### Fixed

- Open long newsletters built from nested tables, which froze the app.
- Stop showing the title of an email as the first line of its body.
- Keep a cleared email signature empty, instead of bringing back the default
  one on the next launch.
- Write the default email signature in the language of the app.
- Fetch all your emails again when you log back in after a logout or a reset
  of the application, instead of leaving the mailbox empty.
- Close the progress dialog of a failed application reset and show the error,
  instead of spinning forever.
- Keep your folders from emptying on web while a tab still runs the previous
  version. That tab now reloads.
- Show the move and label actions of an open email as soon as it loads, and
  its read state right after you change it.
- Show in the hosting settings the period actually synced from each relay.
- Keep the last item of a list clear of the compose button on Android with
  three-button navigation.
- Keep the right-click menu of an email on screen on desktop.

## [0.17.0]

### Added

- Sort your emails into your own folders and labels, from the drawer, the
  email actions, or a selection. A folder or label can fill itself with rules
  on the sender, the subject, or attachments, and takes a color from the
  palette or a custom one.
- Quote the original email below a reply or a forward, shown as it reads,
  instead of copying it into the editor. A forward brings along the images and
  attachments of the original. The quote of a reply starts folded and can be
  removed.
- Paste an image into the body of an email to insert it inline.
- Preview and rename the attachments of an email being written. Image
  attachments show a thumbnail and open in the image viewer, and a right-click
  or a long press on an attachment offers Rename and Remove.
- Cut, copy, paste, and select all from a right-click menu in the email editor
  on web.
- Select a run of emails with a shift-click, and select an email by tapping its
  avatar, in the inbox and the scheduled list.
- Choose the theme color when the dynamic theme is off: the system accent, a
  suggested color, or a custom one. Pick one of the nine Material palette
  styles whichever way the color is chosen.
- Open the links and email addresses of a plain-text email.
- Discover Nostr apps that accept your key on the identity page of the
  onboarding.
- Show an error screen with the details and a prefilled report when the app
  fails to start, instead of a blank page.
- Know when a newer version of Nmail is out: the menu and the settings show
  it, and the about page offers to update, or to reload on web.
- Show a FOSS chip next to the app name on the about page of the FOSS
  version.

### Changed

- Hide from relays which emails are read, archived, filed, or labeled, and
  when. Update Nmail on all your devices at once: older versions do not see
  these changes, nor the emails deleted from this version.
- Delete an email without its sender being able to tell.
- Keep a background picked from a file on web on the device, instead of
  uploading it to your media servers. A background pasted as a link is
  downloaded once instead of loaded from its host on every launch. Web keeps
  all your backgrounds in a gallery, like the other platforms.
- Store the backgrounds of every platform the same way. On Android, iOS,
  Linux, macOS, and Windows, backgrounds added from a file before this version
  are not kept: add them again from the appearance settings.
- Make the soft gradient the default background, shown first in the
  appearance settings. A background you already picked stays.
- Show people from your address book with their contact name and picture in
  the inbox, the email header, the scheduled list, and the recipients of an
  email being written.
- Put Restore first in the actions of an email in the trash, and Unarchive
  first in the archive.
- Rename the manual sync button to Refresh.
- Show the Nostr logo on the network page of the onboarding, and name Nostr in
  its text.
- Show the year of a scheduled date outside the current year, and allow
  scheduling up to five years ahead.
- Confirm a copied sync code on its button instead of with a toast.
- Stop using relay.damus.io by default, recommend blossom.ditto.pub as a media
  server, and connect QR code logins through relay.nmail.li and
  relay.primal.net.

### Fixed

- Keep the Bcc recipients of an email over 32 KB hidden from the other
  recipients.
- Show the subject and recipients of a scheduled email over 32 KB, which
  appeared empty, and open it for editing without a delay.
- Fit the attachments of an email on a phone screen: the header no longer
  overflows, and attachments sit side by side.
- Stop sending the name you gave a Nostr contact in your address book to the
  recipients of your emails. They are named after their public profile.
- Log in with Amber by QR code, which waited without ever connecting.
- Deliver public emails to the relays their recipients read from, instead of
  only when both accounts shared a relay.
- Keep a removed label removed when two devices had applied it before syncing.
- Keep the settings saved by a newer version or another app when saving yours.
- Show the inline images of an email, and apply its style rules.
- Lay out tables, and buttons built from tables, in an email as a browser does.
- Show recipient suggestions right away while writing, instead of waiting on
  relays.
- Copy the text of a plain-text email or of an email's source on web without
  the selection shifting by one character per line.
- Stop a pasted animated GIF background on web from raising an error on every
  frame.
- Open the local mail store when its creation had been interrupted, instead of
  failing on every launch.
- Launch the Linux AppImage and .deb packages, which failed to start.

## [0.16.0]

### Added

- Empty the trash in one tap from the banner at the top of the trash, which
  also shows how many emails it holds.
- Copy an image attachment from the image viewer with a right-click.
- Close the image viewer with Escape or by clicking outside the image.
- Choose how each recipient receives your email: tap a recipient while
  writing to send through SMTP or Nostr, move them to To, Cc or Bcc, or edit
  the address.
- Send through SMTP to a Nostr recipient whose Nostr address also receives
  email. The option names the address the email goes to.
- Copy the email address of your account from the drawer or the account menu.
- Show the account avatar in the scheduled emails on mobile, as in the inbox.
- Write a new email from the scheduled list on mobile, with the compose
  button of the inbox.

### Changed

- Confirm before permanently deleting the selected emails from the trash.
- Require a relay list to use the app. An account without one stays on the
  relay setup screen until the list is found or created, and can switch
  accounts, add one, or log out from the account menu there.
- Keep at least one relay in your relay list in the hosting settings.
- Show the date of an email on the sender's line in the inbox on mobile, which
  leaves the full width to the subject, the preview, and the attachments.
- Remove the location, capture date, and device details from photos and videos
  before they leave the app, whether attached to an email, set as your profile
  picture, or uploaded as a background on web. Their quality is unchanged.
- Edit your profile from the button under your name in the account menu. The
  accounts screen is reached from the settings.
- Show only the name of a Nostr person on their card, without their npub,
  which stays one tap away with Copy npub.
- Show where a scheduled email stands: awaiting confirmation while the
  scheduling service has not answered, scheduled once it accepts, sending
  once part of the recipients have it, and overdue when the send time has
  passed without a send.
- Explain a scheduled email that failed with the message from the scheduling
  service, in place of the preview of its body.
- Keep an email that is being sent from being edited, as the recipients
  already served would receive it a second time.
- Order a scheduled email on mobile like the inbox: the recipient and the
  send time on the first line, the subject under it.

### Fixed

- Show the body of an email in the inbox and scheduled lists as it reads,
  instead of its formatting marks, without the quoted reply or the signature.
- Send the plain-text version of an email as readable text, for the apps that
  show that version, instead of formatting marks.
- Give each sender their own avatar color when a service sends everyone's
  emails from a single address, such as GitHub notifications.
- Select and copy the subject of an open email.
- Keep the close button of the image and PDF viewers clear of the window
  buttons on macOS, and the download button off the edge of the screen.
- Zoom an image across the whole viewer instead of inside its original frame.
- Line up the attachments of an email in the inbox under its subject, with the
  same width on every row, and highlight them with the rest of the row on
  hover.
- Remove the empty line under the subject of an email without a preview in the
  inbox on mobile.
- Reply the way the email arrived: an email received through SMTP gets its
  reply through SMTP instead of Nostr, where the sender would never see it.
- Open a reply instantly, instead of waiting several seconds for its
  recipients to be looked up.
- Quote the replied email without escape characters, doubled or stray line
  breaks, or blank lines at its start and end.
- Keep the last email in the inbox clear of the compose button on mobile.
- Put the scrollbar of the accounts and identities lists at the edge of the
  screen.
- Remove a scheduled email from the list once it is sent or cancelled. A sent
  email is in Sent, a cancelled one is gone.

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
