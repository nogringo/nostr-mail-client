import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail_plus/enough_mail.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:nostr_mail/nostr_mail.dart' as mail;
import 'package:path/path.dart' as p;

import 'config.dart';
import 'keys.dart';
import 'runtime.dart';
import 'seed.dart';

const _dmRelayListKind = 10050;
const _blossomServerListKind = 10063;
const _attachmentBlobFile = 'attachment.pdf';
const _bridgePictureUrl =
    'https://image.nostr.build/22922e08e22b8a4c26816054d03c176f2716fb0dafe5065cdafe09119bb0f0b2.png';

class ScreenshotSeeder {
  final SeederConfig config;
  final ScreenshotSeed seed;
  final ScreenshotKeys keys;

  Uint8List _attachmentBytes = Uint8List(0);

  ScreenshotSeeder({
    required this.config,
    required this.seed,
    required this.keys,
  });

  Future<void> run() async {
    final runStartedAt = DateTime.now().subtract(const Duration(seconds: 5));
    final workDir = Directory(
      p.join('.dart_tool', 'screenshot_seeder', config.locale),
    );
    if (workDir.existsSync()) {
      await workDir.delete(recursive: true);
    }
    await workDir.create(recursive: true);

    await _loadAttachmentBytes();

    final primary = await SeederRuntime.create(
      privateKey: keys.primary.privateKey,
      databasePath: p.join(workDir.path, 'primary.db'),
      bootstrapRelays: [config.bootstrapRelay, config.dataRelay],
      defaultDmRelays: [config.dataRelay],
      blossomServers: [config.blossomServer],
    );

    try {
      await _publishPrimaryBootstrap(primary);
      await _publishPrimaryData(primary);
      await _sendInboxEmails(primary);
      await _publishReadLabels(primary, runStartedAt: runStartedAt);
      stdout.writeln('');
      stdout.writeln('Published screenshot account:');
      stdout.writeln('  npub: ${Nip19.encodePubKey(keys.primary.pubkey)}');
      stdout.writeln(
        '  nsec: ${Nip19.encodePrivateKey(keys.primary.privateKey)}',
      );
    } finally {
      await primary.dispose();
    }
  }

  Future<void> printInboxPreview() async {
    await _loadAttachmentBytes();
    final recipient = mail.NostrRecipient.fromPubkey(keys.primary.pubkey);
    for (var i = 0; i < seed.inbox.length; i++) {
      final email = seed.inbox[i];
      final senderKey = keys.senders[email.senderKey];
      if (senderKey == null) {
        stdout.writeln('  "${email.subject}": no key for ${email.senderKey}');
        continue;
      }

      final message = _buildEmailMessage(
        email: email,
        from: MailAddress(
          email.from,
          email.fromEmail ?? '${Nip19.encodePubKey(senderKey.pubkey)}@nostr',
        ),
        to: recipient.mailAddress,
        date: _dateForEmail(email, i),
      );
      final size = utf8.encode(message.renderMessage()).length;
      final transport = size >= mail.maxInlineSize ? 'blossom blob' : 'inline';
      stdout.writeln(
        '  "${email.subject}": ${email.attachments.length} attachment(s), '
        '$size bytes, $transport',
      );
    }
  }

  Future<void> _loadAttachmentBytes() async {
    if (seed.inbox.every((email) => email.attachments.isEmpty)) return;
    _attachmentBytes = await File(
      p.join(config.seedDir, _attachmentBlobFile),
    ).readAsBytes();
  }

  Future<void> _publishPrimaryBootstrap(SeederRuntime runtime) async {
    await _publishBootstrapRelayList(runtime, keys.primary);
    stdout.writeln('Published kind:10002 to ${config.bootstrapRelay}');
  }

  /// The kind:10002 pointing at the data relay, on the bootstrap relay. Without
  /// it the app never looks at the data relay for that author's profile.
  Future<void> _publishBootstrapRelayList(
    SeederRuntime runtime,
    ScreenshotAccount account,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final relayList = UserRelayList(
      pubKey: account.pubkey,
      relays: {config.dataRelay: ReadWriteMarker.readWrite},
      createdAt: now,
      refreshedTimestamp: now,
    );
    final signed = await _signerFor(account).sign(relayList.toNip65().toEvent());
    await runtime.ndk.config.cache.saveUserRelayList(relayList);
    await runtime.broadcastQueue.broadcast(
      signed,
      relays: [config.bootstrapRelay],
    );
  }

  EventSigner _signerFor(ScreenshotAccount account) => Bip340EventSigner(
    privateKey: account.privateKey,
    publicKey: account.pubkey,
  );

  Future<void> _publishPrimaryData(SeederRuntime runtime) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final profile = seed.profile;
    final metadata = Metadata(
      pubKey: keys.primary.pubkey,
      name: profile.username,
      displayName: profile.displayName,
      about: profile.about,
      updatedAt: now,
    );
    final signedMetadata = await runtime.sign(metadata.toEvent());
    await runtime.ndk.config.cache.saveMetadata(metadata);
    await runtime.broadcastQueue.broadcast(
      signedMetadata,
      relays: [config.dataRelay],
    );
    await _publishBridgeMetadata(runtime);
    await _publishContactProfiles(runtime);

    await _publishRelayListEvent(
      runtime: runtime,
      kind: _dmRelayListKind,
      tags: [
        ['relay', config.dataRelay],
      ],
      label: 'kind:10050',
    );
    await _publishRelayListEvent(
      runtime: runtime,
      kind: _blossomServerListKind,
      tags: [
        ['server', config.blossomServer],
      ],
      label: 'kind:10063',
    );

    final addressBook = NostrAddressBook(
      ndk: runtime.ndk,
      database: runtime.db,
      broadcastQueue: runtime.broadcastQueue,
    );
    for (final contact in seed.contacts) {
      final vCard = _buildVCard(contact);
      await addressBook.upsertVCard(vCard);
    }
    await runtime.broadcastQueue.retryNow();
    stdout.writeln('Published profile and ${seed.contacts.length} contacts');
  }

  Future<void> _publishBridgeMetadata(SeederRuntime runtime) async {
    final bridge = keys.senders['bridge'];
    if (bridge == null) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final metadata = Metadata(
      pubKey: bridge.pubkey,
      name: 'nmail-bridge',
      displayName: 'Nmail Bridge',
      picture: _bridgePictureUrl,
      about: 'SMTP bridge used for Nmail screenshot fixtures.',
      updatedAt: now,
    );
    final signed = await _signerFor(bridge).sign(metadata.toEvent());
    await runtime.ndk.config.cache.saveMetadata(metadata);
    await runtime.broadcastQueue.broadcast(signed, relays: [config.dataRelay]);
    await _publishBootstrapRelayList(runtime, bridge);
    stdout.writeln('Published bridge profile to ${config.dataRelay}');
  }

  Future<void> _publishContactProfiles(SeederRuntime runtime) async {
    var published = 0;
    for (final contact in seed.contacts) {
      final key = contact.key;
      final account = key == null ? null : keys.senders[key];
      if (account == null) continue;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final metadata = Metadata(
        pubKey: account.pubkey,
        name: contact.username,
        displayName: contact.displayName,
        about: contact.about,
        updatedAt: now,
      );
      final signed = await _signerFor(account).sign(metadata.toEvent());
      await runtime.ndk.config.cache.saveMetadata(metadata);
      await runtime.broadcastQueue.broadcast(
        signed,
        relays: [config.dataRelay],
      );
      await _publishBootstrapRelayList(runtime, account);
      published++;
    }
    if (published > 0) {
      stdout.writeln('Published $published contact profiles');
    }
  }

  Future<void> _publishRelayListEvent({
    required SeederRuntime runtime,
    required int kind,
    required List<List<String>> tags,
    required String label,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final event = Nip01Event(
      pubKey: keys.primary.pubkey,
      kind: kind,
      tags: tags,
      content: '',
      createdAt: now,
    );
    final signed = await runtime.sign(event);
    await runtime.ndk.config.cache.saveEvent(signed);
    await runtime.broadcastQueue.broadcast(signed, relays: [config.dataRelay]);
    stdout.writeln('Published $label to ${config.dataRelay}');
  }

  Future<void> _sendInboxEmails(SeederRuntime primary) async {
    final recipient = mail.NostrRecipient.fromPubkey(keys.primary.pubkey);
    for (var i = 0; i < seed.inbox.length; i++) {
      final email = seed.inbox[i];
      final senderKey = _senderKeyFor(email);
      if (senderKey == null) {
        stdout.writeln('Skipping "${email.subject}" from ${email.from}');
        continue;
      }

      final senderRuntime = await SeederRuntime.create(
        privateKey: senderKey.privateKey,
        databasePath: p.join(
          '.dart_tool',
          'screenshot_seeder',
          config.locale,
          '${email.from.hashCode}.db',
        ),
        bootstrapRelays: [config.dataRelay],
        defaultDmRelays: [config.dataRelay],
        blossomServers: [config.blossomServer],
      );
      try {
        final client = senderRuntime.client;
        final message = _buildEmailMessage(
          email: email,
          from: MailAddress(
            email.from,
            email.fromEmail ?? '${Nip19.encodePubKey(senderKey.pubkey)}@nostr',
          ),
          to: recipient.mailAddress,
          date: _dateForEmail(email, i),
        );
        await client.sendMime(
          message,
          to: [recipient],
          mailFrom: email.senderKey == 'bridge' ? email.fromEmail : null,
        );
        await senderRuntime.broadcastQueue.retryNow();
        stdout.writeln('Sent "${email.subject}" from ${email.from}');
      } finally {
        await senderRuntime.dispose();
      }
    }
  }

  Future<void> _publishReadLabels(
    SeederRuntime primary, {
    required DateTime runStartedAt,
  }) async {
    final readSubjects = seed.inbox
        .where((email) => !email.isUnread)
        .map((email) => email.subject)
        .toSet();
    if (readSubjects.isEmpty) return;

    final labelledIds = <String>{};
    for (var attempt = 0; attempt < 6; attempt++) {
      await primary.client.fetchRecent();
      final emails = await primary.client.getInboxEmails();
      final readEmails = _currentRunReadEmails(
        emails: emails,
        readSubjects: readSubjects,
        runStartedAt: runStartedAt,
      );

      for (final email in readEmails) {
        if (!labelledIds.add(email.id)) continue;
        await _publishReadLabel(primary, email.id);
      }

      final foundSubjects = readEmails.map((email) => email.subject).toSet();
      if (readSubjects.difference(foundSubjects).isEmpty) break;

      if (attempt < 5) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    await primary.broadcastQueue.retryNow();

    final emails = await primary.client.getInboxEmails();
    final foundSubjects = _currentRunReadEmails(
      emails: emails,
      readSubjects: readSubjects,
      runStartedAt: runStartedAt,
    ).map((email) => email.subject).toSet();
    final missing = readSubjects.difference(foundSubjects);
    if (missing.isNotEmpty) {
      stdout.writeln('Warning: could not mark as read: ${missing.join(', ')}');
    } else {
      stdout.writeln('Published read labels for ${labelledIds.length} emails');
    }
  }

  List<mail.Email> _currentRunReadEmails({
    required List<mail.Email> emails,
    required Set<String?> readSubjects,
    required DateTime runStartedAt,
  }) {
    final bySubject = <String?, mail.Email>{};
    for (final email in emails) {
      if (!readSubjects.contains(email.subject)) continue;
      if (email.createdAt.isBefore(runStartedAt)) continue;

      final current = bySubject[email.subject];
      if (current == null || email.createdAt.isAfter(current.createdAt)) {
        bySubject[email.subject] = email;
      }
    }
    return bySubject.values.toList(growable: false);
  }

  Future<void> _publishReadLabel(SeederRuntime runtime, String emailId) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final event = Nip01Event(
      pubKey: keys.primary.pubkey,
      kind: mail.labelKind,
      tags: [
        ['L', mail.labelNamespace],
        ['l', 'state:read', mail.labelNamespace],
        ['e', emailId, '', 'labelled'],
      ],
      content: '',
      createdAt: now,
    );
    final signed = await runtime.sign(event);
    await runtime.broadcastQueue.broadcast(signed, relays: [config.dataRelay]);
  }

  ScreenshotAccount? _senderKeyFor(SeedEmail email) =>
      keys.senders[email.senderKey];

  MimeMessage _buildEmailMessage({
    required SeedEmail email,
    required MailAddress from,
    required MailAddress to,
    required DateTime date,
  }) {
    final htmlBody = email.bodyHtml;
    final hasAttachments = email.attachments.isNotEmpty;

    // Mirrors the compose flow: with attachments the root has to be
    // multipart/mixed, or clients hide the attachment.
    final MessageBuilder builder;
    final PartBuilder bodyBuilder;
    if (hasAttachments) {
      builder = MessageBuilder.prepareMultipartMixedMessage();
      bodyBuilder = htmlBody == null
          ? builder
          : builder.addPart(mediaSubtype: MediaSubtype.multipartAlternative);
    } else {
      builder = MessageBuilder.prepareMultipartAlternativeMessage();
      bodyBuilder = builder;
    }

    builder
      ..from = [from]
      ..to = [to]
      ..subject = email.subject
      ..date = date;

    bodyBuilder.addTextPlain(email.body.join('\n\n'));
    if (htmlBody != null) {
      bodyBuilder.addTextHtml(
        htmlBody,
        transferEncoding: TransferEncoding.base64,
      );
    }

    for (final attachment in email.attachments) {
      builder.addBinary(
        _attachmentBytes,
        MediaType.fromText(attachment.mimeType),
        filename: attachment.fileName,
      );
    }

    return builder.buildMimeMessage();
  }

  DateTime _dateForEmail(SeedEmail email, int index) {
    final now = DateTime.now();
    final label = email.relativeDate;
    if (label == null || label.trim().isEmpty) {
      return now.subtract(Duration(hours: index));
    }

    final normalized = _normalizeDateLabel(label);
    if (normalized == 'today' || normalized == 'aujourd hui') {
      return now.subtract(Duration(minutes: 25 + index * 11));
    }

    final day = DateTime(now.year, now.month, now.day);
    if (normalized == 'yesterday' || normalized == 'hier') {
      return _withSeedTime(day.subtract(const Duration(days: 1)), index);
    }

    final weekday = _weekdayForLabel(normalized);
    if (weekday != null) {
      var delta = day.weekday - weekday;
      if (delta <= 0) delta += DateTime.daysPerWeek;
      return _withSeedTime(day.subtract(Duration(days: delta)), index);
    }

    final fixedDate = _fixedDateForLabel(normalized, now);
    if (fixedDate != null) {
      return _withSeedTime(fixedDate, index);
    }

    return now.subtract(Duration(days: index));
  }

  DateTime _withSeedTime(DateTime date, int index) {
    final hour = 16 - (index * 2).clamp(0, 8);
    final minute = const [45, 20, 55, 10][index % 4];
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _normalizeDateLabel(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int? _weekdayForLabel(String value) {
    const weekdays = {
      'mon': DateTime.monday,
      'monday': DateTime.monday,
      'lun': DateTime.monday,
      'tue': DateTime.tuesday,
      'tuesday': DateTime.tuesday,
      'mar': DateTime.tuesday,
      'wed': DateTime.wednesday,
      'wednesday': DateTime.wednesday,
      'mer': DateTime.wednesday,
      'thu': DateTime.thursday,
      'thursday': DateTime.thursday,
      'jeu': DateTime.thursday,
      'fri': DateTime.friday,
      'friday': DateTime.friday,
      'ven': DateTime.friday,
      'sat': DateTime.saturday,
      'saturday': DateTime.saturday,
      'sam': DateTime.saturday,
      'sun': DateTime.sunday,
      'sunday': DateTime.sunday,
      'dim': DateTime.sunday,
    };
    return weekdays[value];
  }

  DateTime? _fixedDateForLabel(String value, DateTime now) {
    const months = {
      'jan': 1,
      'janv': 1,
      'feb': 2,
      'fev': 2,
      'mar': 3,
      'mars': 3,
      'apr': 4,
      'avr': 4,
      'may': 5,
      'mai': 5,
      'jun': 6,
      'juin': 6,
      'jul': 7,
      'juil': 7,
      'aug': 8,
      'aout': 8,
      'sep': 9,
      'sept': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    final parts = value.split(' ');
    int? day;
    int? month;
    for (final part in parts) {
      day ??= int.tryParse(part);
      month ??= months[part];
    }
    if (day == null || month == null) return null;

    var date = DateTime(now.year, month, day);
    final today = DateTime(now.year, now.month, now.day);
    if (date.isAfter(today)) {
      date = DateTime(now.year - 1, month, day);
    }
    return date;
  }

  String _buildVCard(SeedContact contact) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:4.0',
      'UID:${_contactUid(contact)}',
      'FN:${contact.displayName}',
    ];
    final birthday = contact.birthday;
    if (birthday != null) {
      final year = birthday.year?.toString().padLeft(4, '0') ?? '';
      final month = birthday.month.toString().padLeft(2, '0');
      final day = birthday.day.toString().padLeft(2, '0');
      lines.add('BDAY:${year.isEmpty ? '--' : year}$month$day');
    }
    for (final email in contact.emails) {
      lines.add('EMAIL:$email');
    }
    for (final phone in contact.phones) {
      lines.add('TEL:$phone');
    }
    for (final npub in _nostrPubkeysFor(contact)) {
      lines.add('IMPP:nostr:$npub');
    }
    lines.add('END:VCARD');
    return lines.join('\n');
  }

  /// Stable across runs, so a re-run replaces the contact instead of adding a
  /// second one: the uid becomes the `d` tag of the addressable event.
  String _contactUid(SeedContact contact) {
    final fallback = contact.emails.isEmpty
        ? contact.displayName
        : contact.emails.first.split('@').first;
    final key = contact.key ?? _slug(fallback);
    return 'urn:nmail-screenshot:${config.locale}:$key';
  }

  String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  List<String> _nostrPubkeysFor(SeedContact contact) {
    final key = contact.key;
    final account = key == null ? null : keys.senders[key];
    if (account != null) return [Nip19.encodePubKey(account.pubkey)];
    return contact.nostrPubkeys;
  }
}
