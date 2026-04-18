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
