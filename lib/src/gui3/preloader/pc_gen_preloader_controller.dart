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
