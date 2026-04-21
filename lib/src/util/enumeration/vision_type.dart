//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.util.enumeration.VisionType
import 'package:pcgen2/src/base/lang/case_insensitive_string.dart';

/// A dynamic (non-enum) type registry for vision types.
///
/// New types are registered on first access via [getVisionType]. Each unique
/// name maps to a single [VisionType] instance (case-insensitive). This mirrors
/// the Java implementation which used a lazy-built identity map.
final class VisionType {
  static final Map<CaseInsensitiveString, VisionType> _typeMap = {};

  VisionType._();

  static VisionType getVisionType(String s) {
    final key = CaseInsensitiveString(s);
    return _typeMap.putIfAbsent(key, VisionType._);
  }

  /// Resets the registry to the built-in set (clears any runtime-added types).
  static void clearConstants() {
    _typeMap.clear();
  }

  static Iterable<VisionType> getAllVisionTypes() =>
      List.unmodifiable(_typeMap.values);

  @override
  String toString() {
    for (final entry in _typeMap.entries) {
      if (entry.value == this) return entry.key.toString();
    }
    return '';
  }
}
