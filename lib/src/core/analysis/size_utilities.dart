import '../../cdom/enumeration/object_key.dart';
import '../globals.dart';
import '../size_adjustment.dart';

// Utility for size-related queries.
abstract final class SizeUtilities {
  static SizeAdjustment? getDefaultSizeAdjustment() {
    for (final s in Globals.currentDataSet?.sizeAdjustments ?? []) {
      final isDefault = s.get(ObjectKey.isDefaultSize);
      if (isDefault == true) return s;
    }
    return null;
  }
}
