//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.content.LevelCommandFactory
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';

// Identifies a PCClass to be applied with a given number of levels to a PC.
class LevelCommandFactory extends ConcretePrereqObject implements Comparable<LevelCommandFactory> {
  final CDOMSingleRef<PCClass> pcClassRef;
  final String levels; // formula string

  LevelCommandFactory(this.pcClassRef, this.levels);

  String getLevelCount() => levels;
  PCClass getPCClass() => pcClassRef.get();
  String getLSTformat([bool useAny = false]) => pcClassRef.getLSTformat(false);

  @override
  int get hashCode => pcClassRef.hashCode * 29 + levels.hashCode;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! LevelCommandFactory) return false;
    return levels == obj.levels && pcClassRef == obj.pcClassRef;
  }

  @override
  int compareTo(LevelCommandFactory other) {
    final cr = pcClassRef.getLSTformat(false).compareTo(other.pcClassRef.getLSTformat(false));
    if (cr != 0) return cr;
    return levels.compareTo(other.levels);
  }
}
