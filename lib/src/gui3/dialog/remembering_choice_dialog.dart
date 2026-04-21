//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui3.dialog.RememberingChoiceDialog

import 'package:flutter/material.dart';

/// A choice dialog that can remember the user's choice so it doesn't ask again.
class RememberingChoiceDialog extends StatefulWidget {
  final String title;
  final String message;
  final List<String> choices;
  final bool showRememberCheck;

  const RememberingChoiceDialog({
    super.key,
    required this.title,
    required this.message,
    required this.choices,
    this.showRememberCheck = true,
  });

  static Future<({String choice, bool remember})?> show(
    BuildContext context, {
    required String title,
    required String message,
    required List<String> choices,
    bool showRememberCheck = true,
  }) {
    return showDialog<({String choice, bool remember})>(
      context: context,
      builder: (ctx) => RememberingChoiceDialog(
        title: title,
        message: message,
        choices: choices,
        showRememberCheck: showRememberCheck,
      ),
    );
  }

  @override
  State<RememberingChoiceDialog> createState() => _RememberingChoiceDialogState();
}

class _RememberingChoiceDialogState extends State<RememberingChoiceDialog> {
  String? _selected;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.choices.isNotEmpty ? widget.choices.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 12),
          ...widget.choices.map((c) => RadioListTile<String>(
                value: c,
                groupValue: _selected,
                title: Text(c),
                onChanged: (v) => setState(() => _selected = v),
              )),
          if (widget.showRememberCheck) ...[
            const Divider(),
            CheckboxListTile(
              value: _remember,
              onChanged: (v) => setState(() => _remember = v ?? false),
              title: const Text("Don't ask again"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context)
                  .pop((choice: _selected!, remember: _remember)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
