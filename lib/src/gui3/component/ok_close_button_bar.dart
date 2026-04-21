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
// Translation of pcgen.gui3.component.OKCloseButtonBar

import 'package:flutter/material.dart';

/// A standard button bar with OK and Close/Cancel buttons,
/// used at the bottom of preference and dialog panels.
class OKCloseButtonBar extends StatelessWidget {
  final VoidCallback? onOk;
  final VoidCallback? onClose;
  final String okLabel;
  final String closeLabel;

  const OKCloseButtonBar({
    super.key,
    this.onOk,
    this.onClose,
    this.okLabel = 'OK',
    this.closeLabel = 'Close',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onOk != null) ...[
            ElevatedButton(onPressed: onOk, child: Text(okLabel)),
            const SizedBox(width: 8),
          ],
          OutlinedButton(
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
            child: Text(closeLabel),
          ),
        ],
      ),
    );
  }
}
