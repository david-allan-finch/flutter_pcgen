import '../base/cdom_reference.dart';
import '../base/concrete_prereq_object.dart';
import '../reference/cdom_group_ref.dart';
import '../../core/weapon_prof.dart';

// Represents a change to a WeaponProficiency type for a PlayerCharacter.
class ChangeProf extends ConcretePrereqObject {
  final CdomReference<WeaponProf> _source;
  final CdomGroupRef<WeaponProf> _result;

  ChangeProf(CdomReference<WeaponProf> sourceProf, CdomGroupRef<WeaponProf> resultType)
      : _source = sourceProf,
        _result = resultType;

  CdomReference<WeaponProf> getSource() => _source;
  CdomGroupRef<WeaponProf> getResult() => _result;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangeProf) return false;
    return _source == other._source && _result == other._result;
  }

  @override
  int get hashCode => 31 * _source.hashCode + _result.hashCode;

  @override
  String toString() => 'ChangeProf[$_source -> $_result]';
}
