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
// Translation of pcgen.cdom.processor.HitDieLock
import '../content/hit_die.dart';
import '../content/processor.dart';

// A Processor that unconditionally returns a fixed HitDie regardless of input.
class HitDieLock implements Processor<HitDie> {
  final HitDie _hitDie;

  HitDieLock(HitDie die) : _hitDie = die;

  @override
  HitDie applyProcessor(HitDie origHD, Object? context) => _hitDie;

  @override
  String getLSTformat() => _hitDie.getDie().toString();

  @override
  Type getModifiedClass() => HitDie;

  @override
  int get hashCode => _hitDie.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is HitDieLock && obj._hitDie == _hitDie;
}
