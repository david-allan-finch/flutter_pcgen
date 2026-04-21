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
