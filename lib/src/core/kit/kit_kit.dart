import '../../cdom/base/cdom_single_ref.dart';
import '../kit.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitKit extends BaseKit {
  final List<CDOMSingleRef<Kit>> _availableKits = [];
  Map<Kit, List<BaseKit>> _appliedKits = {};

  void addKit(CDOMSingleRef<Kit> ref) { _availableKits.add(ref); }
  List<CDOMSingleRef<Kit>> getKits() => _availableKits;

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _appliedKits = {};
    for (final ref in _availableKits) {
      final addedKit = ref.get();
      final thingsToAdd = <BaseKit>[];
      addedKit.testApplyKit(aPC, thingsToAdd, warnings, true);
      _appliedKits[addedKit] = thingsToAdd;
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    for (final entry in _appliedKits.entries) {
      entry.key.processKit(aPC, entry.value);
    }
  }

  @override
  String getObjectName() => 'Kit';

  @override
  String toString() => _availableKits.map((r) => r.getLSTformat(false)).join('|');
}
