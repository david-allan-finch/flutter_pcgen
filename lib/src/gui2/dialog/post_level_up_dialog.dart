// Translation of pcgen.gui2.dialog.PostLevelUpDialog

import 'package:flutter/material.dart';

/// Dialog shown after a character levels up to make selections.
class PostLevelUpDialog extends StatefulWidget {
  final dynamic character;

  const PostLevelUpDialog({super.key, required this.character});

  static Future<void> showDialog2(BuildContext context, dynamic character) {
    return showDialog(
      context: context,
      builder: (_) => PostLevelUpDialog(character: character),
    );
  }

  @override
  State<PostLevelUpDialog> createState() => _PostLevelUpDialogState();
}

class _PostLevelUpDialogState extends State<PostLevelUpDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Level Up'),
      content: const SizedBox(
        width: 500,
        height: 400,
        child: Center(child: Text('Level up choices')),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
