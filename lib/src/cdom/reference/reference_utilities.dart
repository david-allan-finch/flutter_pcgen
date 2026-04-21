// Copyright (c) Tom Parker, 2007.
//
// Translation of pcgen.cdom.reference.ReferenceUtilities

import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';

/// Utility methods for working with CDOMReference objects.
class ReferenceUtilities {
  ReferenceUtilities._();

  /// Comparator for CDOMReference objects: single refs sort before other refs,
  /// then alphabetically by name.
  static int compareRefs(CDOMReference a, CDOMReference b) {
    final aIsSingle = a is CDOMSingleRef;
    final bIsSingle = b is CDOMSingleRef;
    if (aIsSingle && !bIsSingle) return -1;
    if (!aIsSingle && bIsSingle) return 1;
    return a.getName().compareTo(b.getName());
  }

  /// Joins the LST format of the given references with a separator.
  static String joinLstFormat(
      Iterable<CDOMReference> refCollection, String separator,
      {bool useAny = false}) {
    if (refCollection.isEmpty) return '';
    return refCollection.map((r) => r.getLSTformat(useAny)).join(separator);
  }

  /// Joins the display names of all contained objects across the given references.
  static String joinDisplayNames(
      Iterable<CDOMReference> refCollection, String separator) {
    final names = <String>{};
    for (final ref in refCollection) {
      for (final obj in ref.getContainedObjects()) {
        names.add(obj.getDisplayName());
      }
    }
    return (names.toList()..sort()).join(separator);
  }
}
