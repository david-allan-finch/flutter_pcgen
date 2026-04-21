//
// Copyright 2014 (C) Stefan Radermacher
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
// Translation of pcgen.util.enumeration.Load
/// Encumbrance load categories.
///
/// The [calcEncumberedMove] method preserves the original game movement
/// penalty logic. Display properties (font, color) are intentionally omitted
/// here — they belong in the UI layer.
enum Load {
  light,
  medium,
  heavy,
  overload;

  static Load? getLoadType(String val) {
    return Load.values.firstWhere(
      (l) => l.name.toUpperCase() == val.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown Load value: $val'),
    );
  }

  Load max(Load other) => index >= other.index ? this : other;

  double calcEncumberedMove(double unencumberedMove) {
    return switch (this) {
      Load.light => unencumberedMove,
      Load.medium || Load.heavy => _mediumHeavyMove(unencumberedMove),
      Load.overload => 0.0,
    };
  }

  static double _mediumHeavyMove(double unencumberedMove) {
    if ((unencumberedMove - 5).abs() < 1e-9 ||
        (unencumberedMove - 10).abs() < 1e-9) {
      return 5.0;
    }
    return (unencumberedMove / 15).floorToDouble() * 10 +
        (unencumberedMove.toInt() % 15);
  }
}
