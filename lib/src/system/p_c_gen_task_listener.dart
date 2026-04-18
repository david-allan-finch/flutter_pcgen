// Translation of pcgen.system.PCGenTaskListener

import 'p_c_gen_task_event.dart';

abstract interface class PCGenTaskListener {
  void progressChanged(PCGenTaskEvent event);
  void errorOccurred(PCGenTaskEvent event);
}
