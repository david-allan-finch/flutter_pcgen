//
// Copyright 2012 Vincent Lhote
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
// Translation of pcgen.gui2.dialog.AbstractDialog

import 'package:flutter/material.dart';

/// Base class for PCGen dialogs.
abstract class AbstractDialog extends StatefulWidget {
  const AbstractDialog({super.key});

  /// Shows this dialog and returns when it is closed.
  Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => this,
    );
  }
}

abstract class AbstractDialogState<T extends AbstractDialog> extends State<T> {
  void closeDialog() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) => buildDialog(context);

  Widget buildDialog(BuildContext context);
}
