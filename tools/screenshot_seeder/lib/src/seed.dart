import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'config.dart';

class ScreenshotSeed {
  final String path;
  final SeedProfile profile;
  final List<SeedContact> contacts;
  final List<SeedEmail> inbox;
  final Map<String, dynamic> composeDraft;

  const ScreenshotSeed({
    required this.path,
    required this.profile,
    required this.contacts,
    required this.inbox,
    required this.composeDraft,
  });

  static Future<ScreenshotSeed> load(SeederConfig config) async {
    final path = p.join(config.seedDir, '${config.locale}.json');
    final json =
        jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
    return ScreenshotSeed(
      path: path,
      profile: SeedProfile.fromJson(json['profile'] as Map<String, dynamic>),
      contacts: [
        for (final item in json['contacts'] as List)
          SeedContact.fromJson(item as Map<String, dynamic>),
      ],
      inbox: [
        for (final item in json['inbox'] as List)
          SeedEmail.fromJson(item as Map<String, dynamic>),
      ],
      composeDraft: json['composeDraft'] as Map<String, dynamic>,
    );
  }
}

class SeedProfile {
  final String displayName;
  final String username;
  final String about;

  const SeedProfile({
    required this.displayName,
    required this.username,
    required this.about,
  });

  factory SeedProfile.fromJson(Map<String, dynamic> json) {
    return SeedProfile(
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      about: json['about'] as String,
    );
  }
}

class SeedContact {
  final String? key;
  final String displayName;
  final SeedBirthday? birthday;
  final List<String> emails;
  final List<String> phones;
  final List<String> nostrPubkeys;

  const SeedContact({
    required this.key,
    required this.displayName,
    required this.birthday,
    required this.emails,
    required this.phones,
    required this.nostrPubkeys,
  });

  factory SeedContact.fromJson(Map<String, dynamic> json) {
    return SeedContact(
      key: json['key'] as String?,
      displayName: json['displayName'] as String,
      birthday: json['birthday'] == null
          ? null
          : SeedBirthday.fromJson(json['birthday'] as Map<String, dynamic>),
      emails: List<String>.from(json['emails'] as List? ?? const []),
      phones: List<String>.from(json['phones'] as List? ?? const []),
      nostrPubkeys: List<String>.from(
        json['nostrPubkeys'] as List? ?? const [],
      ),
    );
  }
}

class SeedBirthday {
  final int? year;
  final int month;
  final int day;

  const SeedBirthday({this.year, required this.month, required this.day});

  factory SeedBirthday.fromJson(Map<String, dynamic> json) {
    return SeedBirthday(
      year: json['year'] as int?,
      month: json['month'] as int,
      day: json['day'] as int,
    );
  }
}

class SeedEmail {
  final String from;
  final String senderKey;
  final String? fromEmail;
  final String subject;
  final List<String> body;
  final String? bodyHtml;
  final String? relativeDate;
  final bool isUnread;

  const SeedEmail({
    required this.from,
    required this.senderKey,
    required this.fromEmail,
    required this.subject,
    required this.body,
    required this.bodyHtml,
    required this.relativeDate,
    required this.isUnread,
  });

  factory SeedEmail.fromJson(Map<String, dynamic> json) {
    return SeedEmail(
      from: json['from'] as String,
      senderKey: json['senderKey'] as String,
      fromEmail: json['fromEmail'] as String?,
      subject: json['subject'] as String,
      body: List<String>.from(json['body'] as List),
      bodyHtml: json['bodyHtml'] as String?,
      relativeDate: json['relativeDate'] as String?,
      isUnread: json['isUnread'] as bool? ?? false,
    );
  }
}
