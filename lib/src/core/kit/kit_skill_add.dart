//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.kit.KitSkillAdd
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/skill.dart';

// Transfer object recording skill rank additions for a kit.
class KitSkillAdd {
  final Skill _skill;
  final double _ranks;
  final double _cost;
  final List<Language> _languages;
  final PCClass _pcClass;

  KitSkillAdd(this._skill, this._ranks, this._cost, this._languages, this._pcClass);

  Skill getSkill() => _skill;
  double getRanks() => _ranks;
  double getCost() => _cost;
  List<Language> getLanguages() => _languages;
  PCClass getPCClass() => _pcClass;
}
