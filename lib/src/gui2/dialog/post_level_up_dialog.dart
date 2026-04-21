//
// Copyright James Dempsey, 2012
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
