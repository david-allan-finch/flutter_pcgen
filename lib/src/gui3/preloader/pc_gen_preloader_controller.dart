// Translation of pcgen.gui3.preloader.PCGenPreloaderController

import 'package:flutter/foundation.dart';

/// Controller for the preloader/splash screen — tracks initialization progress.
class PCGenPreloaderController extends ChangeNotifier {
  double _progress = 0.0;
  String _statusMessage = 'Starting up...';
  bool _isComplete = false;

  double get progress => _progress;
  String get statusMessage => _statusMessage;
  bool get isComplete => _isComplete;

  void setProgress(double progress, String message) {
    _progress = progress.clamp(0.0, 1.0);
    _statusMessage = message;
    if (_progress >= 1.0) _isComplete = true;
    notifyListeners();
  }

  void setMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  void complete() {
    _progress = 1.0;
    _isComplete = true;
    notifyListeners();
  }

  void reset() {
    _progress = 0.0;
    _statusMessage = 'Starting up...';
    _isComplete = false;
    notifyListeners();
  }
}
