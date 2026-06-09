import 'package:flutter/material.dart';

class ContactSectionTitle extends StatelessWidget {
  final String text;

  const ContactSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}
