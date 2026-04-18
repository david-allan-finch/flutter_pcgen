import '../reference/cdom_single_ref.dart';
import '../../core/equipment_modifier.dart';

// A reference to a specific EquipmentModifier with optional choice associations.
class EqModRef {
  final CDOMSingleRef<EquipmentModifier> eqMod;
  List<String>? _choices;

  EqModRef(this.eqMod);

  void addChoice(String choice) {
    _choices ??= [];
    _choices!.add(choice);
  }

  CDOMSingleRef<EquipmentModifier> getRef() => eqMod;

  List<String> getChoices() => _choices == null ? const [] : List.of(_choices!);

  @override
  bool operator ==(Object obj) {
    if (obj is! EqModRef) return false;
    if (eqMod != obj.eqMod) return false;
    return _choices == obj._choices;
  }

  @override
  int get hashCode => 3 - eqMod.hashCode;
}
