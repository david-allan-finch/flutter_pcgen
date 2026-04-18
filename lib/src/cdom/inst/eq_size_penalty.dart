import '../../core/bonus/bonus_obj.dart';
import '../base/loadable.dart';

class EqSizePenalty implements Loadable {
  String? _sourceURI;
  String? _penaltyName;
  List<BonusObj>? _bonusList;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _penaltyName = name; }

  @override
  String? getDisplayName() => _penaltyName;

  @override
  String? getKeyName() => _penaltyName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void addBonus(BonusObj bon) {
    _bonusList ??= [];
    _bonusList!.add(bon);
  }

  List<BonusObj> getBonuses() =>
      _bonusList == null ? const [] : List.unmodifiable(_bonusList!);
}
