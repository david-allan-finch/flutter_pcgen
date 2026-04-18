// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.LegalDeityFacet

import '../../base/cdom_reference.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../../core/deity.dart';
import '../../../core/pc_class.dart';
import '../model/class_facet.dart';
import '../prerequisite_facet.dart';

/// Tracks which Deity objects the Player Character may select.
class LegalDeityFacet {
  late ClassFacet classFacet;
  late PrerequisiteFacet prerequisiteFacet;

  /// Returns true if selection of the given Deity is allowed by the PC's classes.
  bool allows(CharID id, Deity? aDeity) {
    if (aDeity == null) return false;
    bool result;
    if (classFacet.isEmpty(id)) {
      result = true;
    } else {
      result = false;
      classLoop:
      for (final aClass in classFacet.getSet(id)) {
        final deityList = aClass.getListFor(
            ListKey.getConstant<CDOMReference<Deity>>('DEITY'));
        if (deityList == null) {
          result = true;
          break;
        } else {
          for (final deityRef in deityList) {
            if (deityRef.contains(aDeity)) {
              result = true;
              break classLoop;
            }
          }
        }
      }
    }
    return result && prerequisiteFacet.qualifies(id, aDeity, aDeity);
  }
}
