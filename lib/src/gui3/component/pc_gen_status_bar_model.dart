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
