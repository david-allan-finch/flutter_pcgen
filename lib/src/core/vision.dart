//
// Copyright 2006 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.core.Vision
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';

/// Represents a vision type with an associated distance formula.
///
/// Example: Darkvision (60'), Lowlight Vision
class Vision extends CDOMObject implements Comparable<Vision> {
  final String visionType;
  final String _distance; // formula string, e.g. "60" or "0"

  Vision(this.visionType, String distance) {
    if (visionType.isEmpty) {
      throw ArgumentError('Vision Type cannot be null or empty');
    }
    _distance = distance;
  }

  /// Get the distance formula string.
  String getDistance() => _distance;

  /// Get the vision type string.
  String getType() => visionType;

  @override
  String toString() {
    final dist = int.tryParse(_distance);
    if (dist != null) {
      return _toStringInt(dist);
    }
    return '$visionType ($_distance)';
  }

  String _toStringInt(int dist) {
    if (dist <= 0) return visionType;
    return "$visionType ($dist')";
  }

  /// Get the display string using the PC to resolve the distance formula.
  String toStringWithPC(dynamic aPC) {
    int dist = 0;
    try {
      final resolved = (aPC as dynamic).getVariableValue(_distance, '') as num;
      dist = resolved.truncate();
    } catch (_) {
      dist = int.tryParse(_distance) ?? 0;
    }
    return _toStringInt(dist);
  }

  @override
  bool operator ==(Object obj) {
    if (obj is Vision) {
      return _distance == obj._distance && visionType == obj.visionType;
    }
    return false;
  }

  @override
  int get hashCode => _distance.hashCode ^ visionType.hashCode;

  @override
  int compareTo(Vision v) {
    return toString().compareTo(v.toString());
  }

  /// Parse a vision string in the format "VisionType (distance')" or "VisionType".
  ///
  /// Throws [ArgumentError] if the string is malformed.
  static Vision getVision(String visionString) {
    if (visionString.contains(',')) {
      throw ArgumentError('Invalid Vision: $visionString. May not contain a comma');
    }

    final openParenLoc = visionString.indexOf('(');
    final closeParenLoc = visionString.indexOf(')');
    final quoteLoc = visionString.indexOf("'");

    String type;
    String distance;

    if (openParenLoc == -1) {
      if (closeParenLoc != -1) {
        throw ArgumentError(
            'Invalid Vision: $visionString. Had close paren without open paren');
      }
      if (quoteLoc != -1) {
        throw ArgumentError(
            'Invalid Vision: $visionString. Had quote without parens');
      }
      type = visionString;
      distance = '0';
    } else {
      if (closeParenLoc != visionString.length - 1) {
        throw ArgumentError(
            'Invalid Vision: $visionString. Close paren not at end of string');
      }
      int endDistance = visionString.length - 1;
      if (quoteLoc != -1) {
        if (quoteLoc == visionString.length - 2) {
          endDistance--;
        } else {
          throw ArgumentError(
              "Invalid Vision: $visionString. Foot character ' not immediately before close paren");
        }
      }
      type = visionString.substring(0, openParenLoc).trim();
      final dist = visionString.substring(openParenLoc + 1, endDistance);
      if (dist.isEmpty) {
        throw ArgumentError('Invalid Vision: $visionString. No Distance provided');
      }
      if (quoteLoc != -1 && int.tryParse(dist) == null) {
        throw ArgumentError(
            "Invalid Vision: $visionString. Vision Distance with Foot character ' was not an integer");
      }
      distance = dist;
    }

    if (type.isEmpty) {
      throw ArgumentError('Invalid Vision: $visionString. No Vision Type provided');
    }

    return Vision(type, distance);
  }

  @override
  bool isType(String str) => false;

  @override
  String getKeyName() => toString();
}
