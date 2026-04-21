import 'package:flutter_pcgen/src/base/util/indirect.dart';

abstract interface class IndirectDependency {
  void addIndirect(Indirect<dynamic> indirect);
}
