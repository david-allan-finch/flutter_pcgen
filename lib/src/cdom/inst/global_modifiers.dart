import '../base/cdom_object.dart';

// Cache of global default modifiers. Never has a type.
class GlobalModifiers extends CDOMObject {
  @override
  bool isType(String type) => false;

  @override
  bool operator ==(Object o) => o is GlobalModifiers && isCDOMEqual(o);

  @override
  int get hashCode => 53281;
}
