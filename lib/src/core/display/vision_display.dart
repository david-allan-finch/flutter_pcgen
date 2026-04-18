// Copyright (c) Tom Parker, 2012.
//
// Translation of pcgen.core.display.VisionDisplay

/// Utilities for formatting a character's vision list for display.
class VisionDisplay {
  VisionDisplay._();

  /// Returns a semicolon-separated string of vision entries from a CDOMObject's
  /// VISIONLIST modified list, resolved against [aPC].
  static String getVisionFromObject(dynamic aPC, dynamic cdo) {
    if (aPC == null) return '';
    final mods = cdo.getListMods('VISIONLIST') as Iterable? ?? const [];
    final parts = <String>[];
    for (final ref in mods) {
      for (final vision in ref.getContainedObjects() as Iterable) {
        parts.add(vision.toStringForPC(aPC) as String);
      }
    }
    return parts.join(';');
  }

  /// Returns a comma-separated string of vision entries from the character's
  /// resolved vision list via [CharacterDisplay].
  static String getVisionFromDisplay(dynamic display) {
    final visions = display.getVisionList() as Iterable? ?? const [];
    return visions.map((v) => v.toString()).join(', ');
  }
}
