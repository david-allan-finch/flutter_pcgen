import '../../../cdom/base/cdom_object.dart';
import '../../../cdom/enumeration/object_key.dart';

// Checks whether a CDOMObject has a new-style CHOOSE token.
final class ChooseActivation {
  ChooseActivation._();

  static bool hasNewChooseToken(CDOMObject po) =>
      po.get(ObjectKey.chooseInfo) != null;
}
