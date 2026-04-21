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
// Translation of pcgen.system.PCGenTaskExecutor

import 'package:flutter_pcgen/src/system/p_c_gen_task.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_task_event.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_task_listener.dart';
import 'package:flutter_pcgen/src/system/progress_container.dart';

/// Runs a queue of PCGenTasks sequentially, aggregating their progress.
class PCGenTaskExecutor extends PCGenTask implements PCGenTaskListener {
  final List<PCGenTask> _tasks = [];
  PCGenTask? _currentTask;

  void addPCGenTask(PCGenTask task) => _tasks.add(task);

  @override
  void run() {
    for (final task in List.of(_tasks)) {
      _currentTask = task;
      task.addPCGenTaskListener(this);
      task.run();
      task.removePCGenTaskListener(this);
    }
    _tasks.clear();
    _currentTask = null;
  }

  @override
  void progressChanged(PCGenTaskEvent event) {
    final ct = _currentTask;
    if (ct != null) {
      setValuesWithMessage(
          ct.getMessage() ?? '',
          ct.getProgress(),
          ct.getMaximum());
    }
  }

  @override
  void errorOccurred(PCGenTaskEvent event) {
    final error = event.getErrorRecord();
    final errorEvent = PCGenTaskEvent(this, errorRecord: error);
    for (final l in List<PCGenTaskListener>.of([])) {
      l.errorOccurred(errorEvent);
    }
  }
}
