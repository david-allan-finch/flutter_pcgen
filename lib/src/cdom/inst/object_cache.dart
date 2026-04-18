import '../base/cdom_object.dart';

// Cache of information for a PlayerCharacter. Never has a type.
class ObjectCache extends CDOMObject {
  @override
  bool isType(String type) => false;
}
