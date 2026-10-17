import 'package:flutter/material.dart';

import 'signature_picker_dialog.dart';

/// Null when dismissed. Otherwise the picked id: a signature id, an empty
/// string for none, or null for the default when [inheritLabel] offers it.
Future<({String? id})?> showSignaturePicker(
  BuildContext context, {
  required String title,
  required String? selectedId,
  String? inheritLabel,
}) => showDialog<({String? id})>(
  context: context,
  builder: (_) => SignaturePickerDialog(
    title: title,
    selectedId: selectedId,
    inheritLabel: inheritLabel,
  ),
);
