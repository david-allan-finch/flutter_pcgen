import '../content/hit_die.dart';
import '../content/processor.dart';

// A Processor that applies a ReferenceFormula to modify a HitDie's die value.
class HitDieFormula implements Processor<HitDie> {
  final dynamic _formula; // ReferenceFormula<Integer>

  HitDieFormula(dynamic refFormula) : _formula = refFormula;

  @override
  HitDie applyProcessor(HitDie origHD, Object? context) =>
      HitDie(_formula.resolve(origHD.getDie()) as int);

  @override
  String getLSTformat() => '%$_formula';

  @override
  Type getModifiedClass() => HitDie;

  @override
  int get hashCode => _formula.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is HitDieFormula && obj._formula == _formula;
}
