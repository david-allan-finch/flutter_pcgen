import '../cdom/base/bonus_container.dart';
import '../cdom/base/loadable.dart';
import '../cdom/base/transition_choice.dart';
import 'bonus/bonus_obj.dart';
import 'kit.dart';

// Represents an AGESET entry from the BioSettings game mode file.
// Groups bonuses and kit transitions applied when a character reaches an age bracket.
class AgeSet implements BonusContainer, Loadable {
  List<BonusObj>? _bonuses;
  List<TransitionChoice<Kit>>? _kits;
  String? _name;
  int _index = 0;
  String? _sourceUri;

  bool hasBonuses() => _bonuses != null && _bonuses!.isNotEmpty;

  int getIndex() => _index;
  void setAgeIndex(int ageSetIndex) => _index = ageSetIndex;

  List<BonusObj> getBonuses() =>
      _bonuses != null ? List.unmodifiable(_bonuses!) : const [];

  void addBonus(BonusObj bon) {
    _bonuses ??= [];
    _bonuses!.add(bon);
  }

  @override
  List<BonusObj> getRawBonusList() => _bonuses ?? const [];

  List<TransitionChoice<Kit>> getKits() =>
      _kits != null ? List.unmodifiable(_kits!) : const [];

  void addKit(TransitionChoice<Kit> tc) {
    _kits ??= [];
    _kits!.add(tc);
  }

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  String getKeyName() => _name ?? '';

  @override
  void setName(String name) => _name = name;

  @override
  String getDisplayName() => _name ?? '';

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
