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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui3.dialog.AboutDialog

import 'package:flutter/material.dart';
import 'about_dialog_controller.dart';

/// About dialog showing PCGen version and credits.
class PCGenAboutDialog extends StatelessWidget {
  final AboutDialogController controller;

  const PCGenAboutDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, AboutDialogController controller) {
    return showDialog(
      context: context,
      builder: (ctx) => PCGenAboutDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, _) => AlertDialog(
        title: const Text('About PCGen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PCGen — RPG Character Generator',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (controller.version.isNotEmpty)
              Text('Version: ${controller.version}'),
            if (controller.buildDate.isNotEmpty)
              Text('Build Date: ${controller.buildDate}'),
            const SizedBox(height: 8),
            Text('Website: ${controller.website}'),
            const SizedBox(height: 16),
            const Text('Open source character generator for tabletop RPGs.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
