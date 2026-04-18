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
