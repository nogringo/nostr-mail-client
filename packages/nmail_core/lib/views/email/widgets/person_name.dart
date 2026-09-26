import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

class PersonName extends StatelessWidget {
  final EmailPerson person;
  final TextStyle? style;

  const PersonName({super.key, required this.person, this.style});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(emailPersonName(person), style: style));
  }
}
