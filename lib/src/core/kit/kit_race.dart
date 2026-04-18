import '../../cdom/base/cdom_single_ref.dart';
import '../kit.dart';
import '../player_character.dart';
import '../race.dart';
import 'base_kit.dart';

class KitRace extends BaseKit {
  CDOMSingleRef<Race>? _theRace;

  void setRace(CDOMSingleRef<Race> ref) { _theRace = ref; }
  CDOMSingleRef<Race>? getRace() => _theRace;

  @override
  void apply(PlayerCharacter aPC) {
    if (_theRace != null) aPC.setRace(_theRace!.get());
  }

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    apply(aPC);
    return true;
  }

  @override
  String getObjectName() => 'Race';

  @override
  String toString() => _theRace?.getLSTformat(false) ?? '';
}
