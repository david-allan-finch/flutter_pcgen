//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.ClassType
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

// Configuration for a class type (Base, Monster, Prestige, etc.).
final class ClassType implements Loadable {
  String? _sourceURI;
  String _name = '';
  String crFormula = '';
  String crMod = '';
  int crModPriority = 0;
  bool xpPenalty = true;
  bool isMonster = false;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  String getKeyName() => _name;

  @override
  String? getDisplayName() => _name;

  @override
  void setName(String name) { _name = name; }

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  ClassType clone() => ClassType()
    .._sourceURI = _sourceURI
    .._name = _name
    ..crFormula = crFormula
    ..crMod = crMod
    ..crModPriority = crModPriority
    ..xpPenalty = xpPenalty
    ..isMonster = isMonster;
}
