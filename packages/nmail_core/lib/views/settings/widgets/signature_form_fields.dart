import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'signature_content_field.dart';
import 'signature_name_field.dart';

class SignatureFormFields extends StatelessWidget {
  final SignatureFormController controller;

  const SignatureFormFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignatureNameField(controller: controller),
        const SizedBox(height: 16),
        SignatureContentField(controller: controller),
      ],
    );
  }
}
