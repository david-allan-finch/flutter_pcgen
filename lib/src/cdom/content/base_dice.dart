import '../../core/roll_info.dart';
import '../base/loadable.dart';

// Defines how a die type changes as size adjustments are applied.
class BaseDice implements Loadable {
  String? _sourceURI;
  String? _dieName;
  final List<RollInfo> _downList = [];
  final List<RollInfo> _upList = [];

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _dieName = name; }

  @override
  String? getDisplayName() => _dieName;

  @override
  String? getKeyName() => _dieName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void addToDownList(RollInfo rollInfo) { _downList.add(rollInfo); }
  void addToUpList(RollInfo rollInfo) { _upList.add(rollInfo); }

  List<RollInfo> getUpSteps() => List.unmodifiable(_upList);
  List<RollInfo> getDownSteps() => List.unmodifiable(_downList);
}
