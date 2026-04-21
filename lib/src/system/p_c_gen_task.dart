//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.system.PCGenTask

import 'package:flutter_pcgen/src/system/p_c_gen_task_event.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_task_listener.dart';
import 'package:flutter_pcgen/src/system/progress_container.dart';

/// Abstract base task that reports progress to registered listeners.
abstract class PCGenTask implements ProgressContainer {
  int _progress = 0;
  int _maximum = 0;
  String? _message;

  final List<PCGenTaskListener> _listeners = [];

  void addPCGenTaskListener(PCGenTaskListener listener) =>
      _listeners.add(listener);

  void removePCGenTaskListener(PCGenTaskListener listener) =>
      _listeners.remove(listener);

  void run();

  @override
  int getMaximum() => _maximum;

  @override
  int getProgress() => _progress;

  @override
  String? getMessage() => _message;

  @override
  void setValues(int progress, int maximum) {
    _progress = progress;
    _maximum = maximum;
    fireProgressChangedEvent();
  }

  @override
  void setValuesWithMessage(String message, int progress, int maximum) {
    _message = message;
    _progress = progress;
    _maximum = maximum;
    fireProgressChangedEvent();
  }

  @override
  void setProgress(int progress) {
    _progress = progress;
    fireProgressChangedEvent();
  }

  @override
  void setProgressWithMessage(String message, int progress) {
    _message = message;
    _progress = progress;
    fireProgressChangedEvent();
  }

  @override
  void setMaximum(int maximum) {
    _maximum = maximum;
    fireProgressChangedEvent();
  }

  @override
  void fireProgressChangedEvent() {
    final event = PCGenTaskEvent(this);
    for (final l in List.of(_listeners)) {
      l.progressChanged(event);
    }
  }
}
