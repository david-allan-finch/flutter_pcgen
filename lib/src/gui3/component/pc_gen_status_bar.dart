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
// Translation of pcgen.gui3.component.PCGenStatusBar (JavaFX version)

import 'package:flutter/material.dart';
import 'pc_gen_status_bar_model.dart';

/// Status bar widget backed by PCGenStatusBarModel.
class PCGenStatusBar extends StatelessWidget {
  final PCGenStatusBarModel model;

  const PCGenStatusBar({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (ctx, _) => Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            if (model.warningMessage != null) ...[
              const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                model.message,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (model.working)
              SizedBox(
                width: 120,
                height: 8,
                child: LinearProgressIndicator(value: model.progress > 0 ? model.progress : null),
              ),
          ],
        ),
      ),
    );
  }
}
