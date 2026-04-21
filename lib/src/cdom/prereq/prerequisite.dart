//
// Prerequisite.java Copyright 2003 (C) Frugal <frugal@purplewombat.co.uk>
//
// This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
// the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.prereq.Prerequisite
import 'package:flutter_pcgen/src/cdom/prereq/prerequisite_operator.dart';

// Storage format for all prerequisites.
class Prerequisite {
  static const String applyKind = 'APPLY';

  String? kind;
  String? key;
  String? subKey;
  List<Prerequisite>? _prerequisites;
  PrerequisiteOperator operator = PrerequisiteOperator.gteq;
  String operand = '1';
  bool totalValues = false;
  bool characterRequired = true;
  bool countMultiples = false;
  bool overrideQualify = false;
  String? categoryName;

  void addPrerequisite(Prerequisite prereq) {
    _prerequisites ??= [];
    _prerequisites!.add(prereq);
  }

  List<Prerequisite> getPrerequisites() {
    if (_prerequisites == null) return const [];
    return List.unmodifiable(_prerequisites!);
  }

  /// Returns a human-readable description of this prerequisite.
  String getDescription() {
    final sb = StringBuffer();
    if (kind != null) sb.write(kind);
    if (key != null) {
      sb.write(':');
      sb.write(key);
    }
    if (subKey != null) {
      sb.write('=');
      sb.write(subKey);
    }
    sb.write(' ');
    sb.write(operator.symbol);
    sb.write(operand);
    return sb.toString();
  }

  /// Evaluate this prerequisite against [aPC] and [caller].
  ///
  /// This is a stub - the full implementation requires the prereq evaluator
  /// infrastructure which checks the prereq kind against registered handlers.
  bool passes(dynamic aPC, dynamic caller) {
    // Deferred to full prerequisite evaluation infrastructure.
    // Return true by default (no blocking).
    return true;
  }

  Prerequisite clone() {
    final copy = Prerequisite()
      ..kind = kind
      ..key = key
      ..subKey = subKey
      ..operator = operator
      ..operand = operand
      ..totalValues = totalValues
      ..characterRequired = characterRequired
      ..countMultiples = countMultiples
      ..overrideQualify = overrideQualify
      ..categoryName = categoryName;
    if (_prerequisites != null) {
      copy._prerequisites = List.of(_prerequisites!.map((p) => p.clone()));
    }
    return copy;
  }
}
