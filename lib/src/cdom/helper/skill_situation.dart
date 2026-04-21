//
// Copyright (c) 2014 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.helper.SkillSituation
import '../../core/skill.dart';

// Holds a skill, the situation name, and the bonus value for that situation.
class SkillSituation {
  final Skill _skill;
  final String _situation;
  final double _bonus;

  SkillSituation(Skill sk, String sit, double sitbonus)
      : _skill = sk,
        _situation = sit,
        _bonus = sitbonus;

  Skill getSkill() => _skill;
  String getSituation() => _situation;
  double getSituationBonus() => _bonus;
}
