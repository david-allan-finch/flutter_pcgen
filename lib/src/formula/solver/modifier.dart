import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';

abstract interface class Modifier<T> {
  T process(T input, EvaluationManager manager);
  int getPriority();
  FormatManager<T> getFormatManager();
  String getIdentification();
  String getInstructions();
}
