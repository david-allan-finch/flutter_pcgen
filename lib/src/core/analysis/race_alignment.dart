import '../../../cdom/base/cdom_object.dart';
import '../pc_alignment.dart';
import 'alignment_converter.dart';

// Checks whether a race or other CDOMObject allows a given alignment.
final class RaceAlignment {
  RaceAlignment._();

  static bool canBeAlignment(CDOMObject r, PCAlignment align) {
    if (r.hasPrerequisites()) {
      for (final prereq in r.getPrerequisiteList()) {
        if ('ALIGN'.toLowerCase() == prereq.getKind()?.toLowerCase()) {
          final mapped = AlignmentConverter.getPCAlignment(prereq.getKey());
          return align == mapped;
        }
      }
    }
    return true;
  }
}
