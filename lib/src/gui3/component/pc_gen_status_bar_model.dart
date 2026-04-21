// Translation of pcgen.gui3.component.PCGenStatusBarModel

import 'package:flutter/foundation.dart';

/// Model for the PCGen status bar — progress, message, and status icon.
class PCGenStatusBarModel extends ChangeNotifier {
  String _message = '';
  double _progress = 0.0;
  bool _working = false;
  String? _warningMessage;

  String get message => _message;
  double get progress => _progress;
  bool get working => _working;
  String? get warningMessage => _warningMessage;

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void setProgress(double progress) {
    _progress = progress.clamp(0.0, 1.0);
    _working = _progress > 0.0 && _progress < 1.0;
    notifyListeners();
  }

  void startWorking(String message) {
    _message = message;
    _working = true;
    _progress = 0.0;
    notifyListeners();
  }

  void stopWorking() {
    _working = false;
    _progress = 0.0;
    notifyListeners();
  }

  void setWarning(String? warning) {
    _warningMessage = warning;
    notifyListeners();
  }
}
