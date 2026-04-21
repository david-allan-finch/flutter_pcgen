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
// Translation of pcgen.cdom.content.HitDie
// Represents the hit die for a class (d4, d6, d8, d10, d12).
class HitDie {
  final int _die;

  const HitDie(this._die);

  int getDie() => _die;

  @override
  String toString() => 'd$_die';

  @override
  bool operator ==(Object other) => other is HitDie && _die == other._die;

  @override
  int get hashCode => _die.hashCode;
}
