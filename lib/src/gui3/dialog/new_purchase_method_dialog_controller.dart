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
// Translation of pcgen.gui3.dialog.NewPurchaseMethodDialogController

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui3/dialog/new_purchase_method_model.dart';

/// Controller for the New Purchase Method dialog.
class NewPurchaseMethodDialogController {
  final NewPurchaseMethodModel model = NewPurchaseMethodModel();

  Future<Map<String, dynamic>?> show(BuildContext context) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _NewPurchaseMethodDialog(controller: this),
    );
  }
}

class _NewPurchaseMethodDialog extends StatelessWidget {
  final NewPurchaseMethodDialogController controller;
  const _NewPurchaseMethodDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.model,
      builder: (ctx, _) => AlertDialog(
        title: const Text('New Purchase Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: controller.model.setName,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Points',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null) controller.model.setPoints(n);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.model.isValid
                ? () => Navigator.of(ctx).pop({
                      'name': controller.model.name,
                      'points': controller.model.points,
                    })
                : null,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
