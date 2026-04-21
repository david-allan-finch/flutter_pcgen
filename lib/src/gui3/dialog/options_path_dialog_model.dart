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
// Translation of pcgen.gui3.dialog.OptionsPathDialogModel

import 'package:flutter/foundation.dart';

/// Model for the Options Path dialog — lets the user choose where PCGen
/// stores its settings files.
class OptionsPathDialogModel extends ChangeNotifier {
  String _pcgenFilesPath = '';
  String _backupPath = '';
  bool _useDefaultPath = true;

  String get pcgenFilesPath => _pcgenFilesPath;
  String get backupPath => _backupPath;
  bool get useDefaultPath => _useDefaultPath;

  void setPcgenFilesPath(String path) {
    _pcgenFilesPath = path;
    notifyListeners();
  }

  void setBackupPath(String path) {
    _backupPath = path;
    notifyListeners();
  }

  void setUseDefaultPath(bool value) {
    _useDefaultPath = value;
    notifyListeners();
  }
}
