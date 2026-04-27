//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.BonusSpellInfo
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

// Defines how many bonus spells a caster gets per spell level based on stat score.
class BonusSpellInfo implements Loadable {
  String? _sourceURI;
  int _statRange = 0;
  int _spellLevel = 0;
  int _statScore = 0;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) {
    final intValue = int.tryParse(name);
    if (intValue == null || intValue < 1) {
      throw ArgumentError('Name must be an integer >= 1, found: $name');
    }
    _spellLevel = intValue;
  }

  @override
  String getDisplayName() => _spellLevel.toString();

  @override
  String getKeyName() => getDisplayName();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setStatRange(int range) { _statRange = range; }
  void setStatScore(int score) { _statScore = score; }

  bool isValid() => _spellLevel > 0 && _statRange > 0 && _statScore > 0;
  int getStatScore() => _statScore;
  int getStatRange() => _statRange;
  int getSpellLevel() => _spellLevel;
}
