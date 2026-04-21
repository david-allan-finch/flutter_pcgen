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
// Translation of pcgen.cdom.processor.HitDieStep
import '../content/hit_die.dart';
import '../content/processor.dart';

// A Processor that steps a HitDie up or down a fixed number of die-size steps.
class HitDieStep implements Processor<HitDie> {
  final int _numSteps;
  final HitDie? _dieLimit;

  HitDieStep(int steps, HitDie? stopAt)
      : _numSteps = steps,
        _dieLimit = stopAt {
    if (steps == 0) throw ArgumentError('Steps for HitDieStep cannot be zero');
  }

  @override
  HitDie applyProcessor(HitDie origHD, Object? context) {
    int steps = _numSteps;
    HitDie currentDie = origHD;
    while (steps != 0) {
      if (currentDie == _dieLimit) return currentDie;
      if (steps > 0) {
        currentDie = currentDie.getNext();
        steps--;
      } else {
        currentDie = currentDie.getPrevious();
        steps++;
      }
    }
    return currentDie;
  }

  @override
  String getLSTformat() {
    final sb = StringBuffer('%');
    if (_dieLimit == null) sb.write('H');
    sb.write(_numSteps > 0 ? 'up' : 'down');
    sb.write(_numSteps.abs());
    return sb.toString();
  }

  @override
  Type getModifiedClass() => HitDie;

  @override
  int get hashCode =>
      _dieLimit == null ? _numSteps : _numSteps + _dieLimit.hashCode * 29;

  @override
  bool operator ==(Object obj) =>
      obj is HitDieStep &&
      obj._numSteps == _numSteps &&
      obj._dieLimit == _dieLimit;
}
