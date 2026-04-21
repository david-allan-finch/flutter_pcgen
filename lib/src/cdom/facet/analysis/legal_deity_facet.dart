// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.LegalDeityFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/prerequisite_facet.dart';

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
