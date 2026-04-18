// BonusManager.dart
// Translated from pcgen/core/BonusManager.java

import '../cdom/base/constants.dart';
import '../cdom/base/formula_factory.dart';
import '../cdom/base/cdom_object.dart';
import '../cdom/enumeration/string_key.dart';
import 'player_character.dart';
import 'equipment.dart';
import 'equipment_modifier.dart';
import 'ability.dart';
import 'pc_class.dart';
import 'pc_stat.dart';
import 'settings_handler.dart';
import 'bonus/bonus_obj.dart';
import 'bonus/bonus_pair.dart';
import 'bonus/util/missing_object.dart';
import 'analysis/choose_activation.dart';
import 'utils/core_utility.dart';

class TempBonusInfo {
  final Object source;
  final Object target;

  TempBonusInfo(this.source, this.target);
}

class BonusManager {
  static const String _valueTokenReplacement = '%LIST';
  static const String _listTokenReplacement = 'LIST';
  static const String _varTokenReplacement = '%VAR';

  static final List<String> _noAssocList = [''];

  Map<String, String> _activeBonusMap = {};
  Map<String, double> _cachedActiveBonusSumsMap = {};
  // IdentityHashMap -> regular Map (identity semantics dropped)
  Map<BonusObj, Object> _activeBonusBySource = {};
  final Map<BonusObj, TempBonusInfo> _tempBonusBySource = {};
  final Set<String> _tempBonusFilters = {};

  final PlayerCharacter pc;
  Map<String, String>? _checkpointMap;

  BonusManager(this.pc);

  /// Total bonus for the fully qualified bonus type from the activeBonus map.
  double _sumActiveBonusMap(String? fullyQualifiedBonusType) {
    double bonus = 0;
    if (fullyQualifiedBonusType == null) {
      // log: Unable to sum BONUS when request is null
      return bonus;
    }

    fullyQualifiedBonusType = fullyQualifiedBonusType.toUpperCase();
    if (_cachedActiveBonusSumsMap.containsKey(fullyQualifiedBonusType)) {
      return _cachedActiveBonusSumsMap[fullyQualifiedBonusType]!;
    }

    final List<String> aList = [];
    bool found = false;

    for (final String fullyQualifiedCurrentBonus in _activeBonusMap.keys) {
      if (aList.contains(fullyQualifiedCurrentBonus)) {
        continue;
      }

      String currentTypedBonusNameInfo = fullyQualifiedCurrentBonus;

      if (currentTypedBonusNameInfo.endsWith('.STACK')) {
        currentTypedBonusNameInfo =
            currentTypedBonusNameInfo.substring(0, currentTypedBonusNameInfo.length - 6);
      } else if (currentTypedBonusNameInfo.endsWith('.REPLACE')) {
        currentTypedBonusNameInfo =
            currentTypedBonusNameInfo.substring(0, currentTypedBonusNameInfo.length - 8);
      }

      if ((currentTypedBonusNameInfo.length > fullyQualifiedBonusType.length) &&
          !currentTypedBonusNameInfo.startsWith('$fullyQualifiedBonusType:')) {
        continue;
      }

      if (currentTypedBonusNameInfo.startsWith(fullyQualifiedBonusType)) {
        found = true;
        aList.add(currentTypedBonusNameInfo);
        aList.add('$currentTypedBonusNameInfo.STACK');
        aList.add('$currentTypedBonusNameInfo.REPLACE');

        final double aBonus = _getActiveBonusForMapKey(currentTypedBonusNameInfo, double.nan);
        final double replaceBonus =
            _getActiveBonusForMapKey('$currentTypedBonusNameInfo.REPLACE', double.nan);
        final double stackBonus =
            _getActiveBonusForMapKey('$currentTypedBonusNameInfo.STACK', 0);

        if (aBonus.isNaN) {
          if (!replaceBonus.isNaN) {
            bonus += replaceBonus;
          }
        } else if (replaceBonus.isNaN) {
          bonus += aBonus;
        } else {
          bonus += aBonus > replaceBonus ? aBonus : replaceBonus;
        }

        bonus += stackBonus;
      }
    }

    if (found) {
      _cachedActiveBonusSumsMap[fullyQualifiedBonusType] = bonus;
    }
    return bonus;
  }

  double _getActiveBonusForMapKey(String fullyQualifiedBonusType, double defaultValue) {
    fullyQualifiedBonusType = fullyQualifiedBonusType.toUpperCase();
    final String? regVal = _activeBonusMap[fullyQualifiedBonusType];
    if (regVal != null) {
      return double.parse(regVal);
    }
    return defaultValue;
  }

  double getBonusDueToType(String bonusName, String bonusInfo, String bonusType) {
    final String typeString = '$bonusName.$bonusInfo:$bonusType';
    return _sumActiveBonusMap(typeString);
  }

  double getTotalBonusTo(String bonusName, String bonusInfo) {
    final String prefix = '$bonusName.$bonusInfo';
    return _sumActiveBonusMap(prefix);
  }

  String getSpellBonusType(String bonusName, String bonusInfo) {
    String prefix = '$bonusName.$bonusInfo';
    prefix = prefix.toUpperCase();

    for (final String fullyQualifiedBonusType in _activeBonusMap.keys) {
      String typedBonusNameInfo = fullyQualifiedBonusType;

      if (typedBonusNameInfo.endsWith('.STACK')) {
        typedBonusNameInfo =
            typedBonusNameInfo.substring(0, typedBonusNameInfo.length - 6);
      } else if (typedBonusNameInfo.endsWith('.REPLACE')) {
        typedBonusNameInfo =
            typedBonusNameInfo.substring(0, typedBonusNameInfo.length - 8);
      }

      if ((typedBonusNameInfo.length > prefix.length) &&
          !typedBonusNameInfo.startsWith('$prefix:')) {
        continue;
      }

      if (typedBonusNameInfo.startsWith(prefix)) {
        final int typeIndex = typedBonusNameInfo.indexOf(':');
        if (typeIndex > 0) {
          return fullyQualifiedBonusType.substring(typeIndex + 1);
        }
        return ''; // Constants.EMPTY_STRING
      }
    }

    return '';
  }

  /// Build the bonus HashMap from all active BonusObj's
  void buildActiveBonusMap() {
    _activeBonusMap = {};
    _cachedActiveBonusSumsMap = {};
    Map<String, String> nonStackMap = {};
    Map<String, String> stackMap = {};
    final Set<BonusObj> processedBonuses = {};

    // First pass: static bonuses
    for (final BonusObj bonus in getActiveBonusList()) {
      if (!bonus.isValueStatic()) {
        continue;
      }

      final Object? source = _getSourceObject(bonus);
      if (source == null) {
        // log: BONUS ignored due to no creator
        continue;
      }

      processedBonuses.add(bonus);
      for (final BonusPair bp in getStringListFromBonus(bonus)) {
        final double iBonus = bp.resolve(pc).toDouble();
        _setActiveBonusStack(iBonus, bp.fullyQualifiedBonusType, nonStackMap, stackMap);
        _totalBonusesForType(nonStackMap, stackMap, bp.fullyQualifiedBonusType, _activeBonusMap);
      }
    }

    // Second pass: computed bonuses
    for (final BonusObj bonus in getActiveBonusList()) {
      if (processedBonuses.contains(bonus)) {
        continue;
      }

      final Object? anObj = _getSourceObject(bonus);
      if (anObj == null) {
        continue;
      }

      try {
        _processBonus(bonus, {}, processedBonuses, nonStackMap, stackMap);
      } catch (e) {
        // log: ${e.toString()}
      }
    }
  }

  static void _totalBonusesForType(
    Map<String, String> nonStackMap,
    Map<String, String> stackMap,
    String? fullyQualifiedBonusType,
    Map<String, String> targetMap,
  ) {
    if (fullyQualifiedBonusType != null) {
      fullyQualifiedBonusType = fullyQualifiedBonusType.toUpperCase();
    }
    final String? nonStackString = nonStackMap[fullyQualifiedBonusType];
    final double nonStackVal = nonStackString == null ? 0.0 : double.parse(nonStackString);
    final String? stackString = stackMap[fullyQualifiedBonusType];
    final double stackVal = stackString == null ? 0.0 : double.parse(stackString);
    final double fullValue = nonStackVal + stackVal;
    _putActiveBonusMap(fullyQualifiedBonusType!, fullValue.toString(), targetMap);
  }

  List<BonusObj> getActiveBonusList() {
    return _activeBonusBySource.keys.toList();
  }

  void setActiveBonusList() {
    _activeBonusBySource = _getAllActiveBonuses();
  }

  String listBonusesFor(String bonusName, String bonusInfo) {
    final String prefix = '$bonusName.$bonusInfo';
    final StringBuffer buf = StringBuffer();
    final List<String> aList = [];

    final List<String> keys = _activeBonusMap.keys
        .where((k) => k.startsWith(prefix))
        .toList()
      ..sort();

    for (final String fullyQualifiedBonusType in keys) {
      if (fullyQualifiedBonusType.endsWith('.REPLACE')) {
        aList.add(fullyQualifiedBonusType);
      } else {
        String reason = '';
        if (fullyQualifiedBonusType.length > prefix.length) {
          reason = fullyQualifiedBonusType.substring(prefix.length + 1);
        }

        final int b = _getActiveBonusForMapKey(fullyQualifiedBonusType, 0).toInt();
        if (b == 0) continue;

        if (reason != 'NULL' && reason.isNotEmpty) {
          if (buf.isNotEmpty) buf.write(', ');
          buf.write('$reason ');
        }
        buf.write(_deltaToString(b));
      }
    }

    for (final String replaceKey in aList) {
      if (replaceKey.length > 7) {
        final String aKey = replaceKey.substring(0, replaceKey.length - 8);
        final double replaceBonus = _getActiveBonusForMapKey(replaceKey, 0);
        double aBonus = _getActiveBonusForMapKey(aKey, 0);
        aBonus += _getActiveBonusForMapKey('$aKey.STACK', 0);

        final int b = replaceBonus > aBonus ? replaceBonus.toInt() : aBonus.toInt();
        if (b == 0) continue;

        if (buf.isNotEmpty) buf.write(', ');
        final String reason = aKey.substring(prefix.length + 1);
        if (reason != 'NULL') buf.write('$reason ');
        buf.write(_deltaToString(b));
      }
    }

    return buf.toString();
  }

  static String _deltaToString(int val) {
    return val >= 0 ? '+$val' : '$val';
  }

  void _processBonus(
    BonusObj aBonus,
    Set<BonusObj> prevProcessed,
    Set<BonusObj> processedBonuses,
    Map<String, String> nonStackMap,
    Map<String, String> stackMap,
  ) {
    if (prevProcessed.contains(aBonus)) {
      // log: Ignoring bonus loop for $aBonus
      return;
    }
    prevProcessed.add(aBonus);

    final List<BonusObj> aList = [];
    for (final BonusObj newBonus in getActiveBonusList()) {
      if (processedBonuses.contains(newBonus)) continue;
      if (aBonus.getDependsOn(newBonus.getUnparsedBonusInfoList()) ||
          aBonus.getDependsOnBonusName(newBonus.getBonusName())) {
        aList.add(newBonus);
      }
    }

    for (final BonusObj newBonus in aList) {
      _processBonus(newBonus, prevProcessed, processedBonuses, nonStackMap, stackMap);
    }

    if (processedBonuses.contains(aBonus)) {
      return;
    }

    processedBonuses.add(aBonus);

    final Object? anObj = _getSourceObject(aBonus);
    if (anObj == null) {
      prevProcessed.remove(aBonus);
      return;
    }

    for (final BonusPair bp in getStringListFromBonus(aBonus)) {
      final double iBonus = bp.resolve(pc).toDouble();
      _setActiveBonusStack(iBonus, bp.fullyQualifiedBonusType, nonStackMap, stackMap);
      _totalBonusesForType(nonStackMap, stackMap, bp.fullyQualifiedBonusType, _activeBonusMap);
    }
    prevProcessed.remove(aBonus);
  }

  static void _setActiveBonusStack(
    double bonus,
    String? fullyQualifiedBonusType,
    Map<String, String> nonStackBonusMap,
    Map<String, String> stackingBonusMap,
  ) {
    if (fullyQualifiedBonusType == null) return;

    fullyQualifiedBonusType = fullyQualifiedBonusType.toUpperCase();

    if (!fullyQualifiedBonusType.startsWith('ITEMWEIGHT') &&
        !fullyQualifiedBonusType.startsWith('ITEMCOST') &&
        !fullyQualifiedBonusType.startsWith('ITEMCAPACITY') &&
        !fullyQualifiedBonusType.startsWith('LOADMULT') &&
        !fullyQualifiedBonusType.startsWith('FEAT') &&
        !fullyQualifiedBonusType.contains('DAMAGEMULT')) {
      bonus = bonus.truncateToDouble();
    }

    // default to non-stacking
    int index = -1;

    final List<String> parts = fullyQualifiedBonusType.split(':');
    if (parts.length == 2) {
      final String aString = parts[1];
      index = SettingsHandler.getGameAsProperty()
              .getBonusStackList()
              .indexOf(aString);
    } else {
      index = 1; // un-named bonuses stack
    }

    if (fullyQualifiedBonusType.endsWith('.STACK') ||
        fullyQualifiedBonusType.endsWith('.REPLACE')) {
      index = 1;
    }

    if (bonus < 0) {
      index = 1;
    }

    if (index == -1) {
      // non-stacking
      final String? aVal = nonStackBonusMap[fullyQualifiedBonusType];
      if (aVal == null) {
        _putActiveBonusMap(fullyQualifiedBonusType, bonus.toString(), nonStackBonusMap);
      } else {
        final double existingBonus = double.parse(aVal);
        _putActiveBonusMap(
          fullyQualifiedBonusType,
          (bonus > existingBonus ? bonus : existingBonus).toString(),
          nonStackBonusMap,
        );
      }
    } else {
      // stacking
      final String? aVal = stackingBonusMap[fullyQualifiedBonusType];
      if (aVal == null) {
        _putActiveBonusMap(fullyQualifiedBonusType, bonus.toString(), stackingBonusMap);
      } else {
        _putActiveBonusMap(
          fullyQualifiedBonusType,
          (bonus + double.parse(aVal)).toString(),
          stackingBonusMap,
        );
      }
    }
  }

  static void _putActiveBonusMap(
    String fullyQualifiedBonusType,
    String bonusValue,
    Map<String, String> bonusMap,
  ) {
    if (fullyQualifiedBonusType.toUpperCase() == 'SKILL.LIST') {
      return;
    }
    bonusMap[fullyQualifiedBonusType] = bonusValue;
  }

  int getPartialStatBonusFor(dynamic stat, bool useTemp, bool useEquip) {
    final String statAbbr = stat.getKeyName() as String;
    final String prefix = 'STAT.$statAbbr';
    final Map<String, String> bonusMap = {};
    final Map<String, String> nonStackMap = {};
    final Map<String, String> stackMap = {};

    for (final BonusObj bonus in getActiveBonusList()) {
      if (pc.isApplied(bonus) && bonus.getBonusName() == 'STAT') {
        bool found = false;
        final Object? co = _getSourceObject(bonus);
        for (final Object element in bonus.getBonusInfoList()) {
          if (element == stat) {
            found = true;
            break;
          }
          if (element is MissingObject) {
            final String name = element.getObjectName();
            if (('%LIST' == name || 'LIST' == name) && co is CDOMObject) {
              for (final String assoc in pc.getConsolidatedAssociationList(co)) {
                if (assoc.contains(statAbbr)) {
                  found = true;
                  break;
                }
              }
            }
          }
        }
        if (!found) continue;

        bool addIt;
        if (co is Equipment || co is EquipmentModifier) {
          addIt = useEquip;
        } else if (co is Ability) {
          final List<String> types = co.getTypes();
          addIt = types.contains('Equipment') ? useEquip : true;
        } else if (_tempBonusBySource.containsKey(bonus)) {
          addIt = useTemp;
        } else {
          addIt = true;
        }

        if (addIt) {
          for (final BonusPair bp in getStringListFromBonus(bonus)) {
            if (bp.fullyQualifiedBonusType.startsWith(prefix)) {
              _setActiveBonusStack(
                  bp.resolve(pc).toDouble(), bp.fullyQualifiedBonusType, nonStackMap, stackMap);
              _totalBonusesForType(nonStackMap, stackMap, bp.fullyQualifiedBonusType, bonusMap);
            }
          }
        }
      }
    }

    int total = 0;
    for (final String s in bonusMap.values) {
      total += double.parse(s).toInt();
    }
    return total;
  }

  BonusManager buildDeepClone(PlayerCharacter apc) {
    final BonusManager clone = BonusManager(apc);
    clone._activeBonusBySource.addAll(_activeBonusBySource);
    clone._tempBonusBySource.addAll(_tempBonusBySource);
    clone._activeBonusMap.addAll(_activeBonusMap);
    clone._tempBonusFilters.addAll(_tempBonusFilters);
    return clone;
  }

  void checkpointBonusMap() {
    _checkpointMap = Map.from(_activeBonusMap);
  }

  bool compareToCheckpoint() {
    if (_checkpointMap == null) return false;
    if (_checkpointMap!.length != _activeBonusMap.length) return false;
    for (final entry in _checkpointMap!.entries) {
      if (_activeBonusMap[entry.key] != entry.value) return false;
    }
    return true;
  }

  Map<BonusObj, TempBonusInfo> getTempBonusMap() {
    return Map.from(_tempBonusBySource);
  }

  Map<String, String> getBonuses(String bonusName, String bonusInfo) {
    final Map<String, String> returnMap = {};
    final String prefix = '$bonusName.$bonusInfo.';
    for (final entry in _activeBonusMap.entries) {
      if (entry.key.startsWith(prefix)) {
        returnMap[entry.key] = entry.value;
      }
    }
    return returnMap;
  }

  TempBonusInfo addTempBonus(BonusObj bonus, Object source, Object target) {
    final TempBonusInfo tempBonusInfo = TempBonusInfo(source, target);
    _tempBonusBySource[bonus] = tempBonusInfo;
    return tempBonusInfo;
  }

  void removeTempBonus(BonusObj bonus) {
    _tempBonusBySource.remove(bonus);
  }

  List<String> getNamedTempBonusList() {
    final List<String> aList = [];
    final Map<BonusObj, TempBonusInfo> filtered = _getFilteredTempBonusList();

    for (final entry in filtered.entries) {
      final BonusObj aBonus = entry.key;
      if (!pc.isApplied(aBonus)) continue;
      final Object? aCreator = entry.value.source;
      if (aCreator == null) continue;
      final String aName = (aCreator as CDOMObject).getKeyName();
      if (!aList.contains(aName)) {
        aList.add(aName);
      }
    }
    return aList;
  }

  List<String> getNamedTempBonusDescList() {
    final List<String> aList = [];
    final Map<BonusObj, TempBonusInfo> filtered = _getFilteredTempBonusList();

    for (final entry in filtered.entries) {
      final BonusObj aBonus = entry.key;
      if (!pc.isApplied(aBonus)) continue;
      final Object? aCreator = entry.value.source;
      if (aCreator == null) continue;
      final String aDesc = (aCreator as CDOMObject).getSafe(StringKey.tempDescription) as String? ?? '';
      if (!aList.contains(aDesc)) {
        aList.add(aDesc);
      }
    }
    return aList;
  }

  Map<BonusObj, TempBonusInfo> _getFilteredTempBonusList() {
    final Map<BonusObj, TempBonusInfo> ret = {};
    for (final entry in _tempBonusBySource.entries) {
      // stub: BonusDisplay.getBonusDisplayName not yet translated
      // if (!_tempBonusFilters.contains(getBonusDisplayName(entry.value))) {
      ret[entry.key] = entry.value;
      // }
    }
    return ret;
  }

  Set<String> getTempBonusFilters() => _tempBonusFilters;

  void addTempBonusFilter(String bonusStr) => _tempBonusFilters.add(bonusStr);

  void removeTempBonusFilter(String bonusStr) => _tempBonusFilters.remove(bonusStr);

  Map<BonusObj, Object> _getTempBonuses() {
    final Map<BonusObj, Object> map = {};
    _getFilteredTempBonusList().forEach((bonus, value) {
      pc.setApplied(bonus, false);
      final Object source = value.source;
      final CDOMObject? cdomsource = source is CDOMObject ? source : null;
      if (bonus.qualifies(pc, cdomsource)) {
        pc.setApplied(bonus, true);
      }
      if (pc.isApplied(bonus)) {
        map[bonus] = source;
      }
    });
    return map;
  }

  Map<BonusObj, TempBonusInfo> getTempBonusMapFiltered(String aCreator, String aTarget) {
    final Map<BonusObj, TempBonusInfo> aMap = {};

    for (final entry in _tempBonusBySource.entries) {
      final BonusObj bonus = entry.key;
      final TempBonusInfo tbi = entry.value;
      final Object aTO = tbi.target;
      final Object aCO = tbi.source;

      String targetName = '';
      String creatorName = '';

      if (aCO is CDOMObject) {
        creatorName = aCO.getKeyName();
      }
      if (aTO is PlayerCharacter) {
        targetName = aTO.getName();
      } else if (aTO is CDOMObject) {
        targetName = aTO.getKeyName();
      }

      if (creatorName == aCreator && targetName == aTarget) {
        aMap[bonus] = tbi;
      }
    }
    return aMap;
  }

  String getBonusContext(BonusObj bo, bool shortForm) {
    final StringBuffer sb = StringBuffer();
    bool bEmpty = true;
    sb.write('[');

    if (bo.hasPrerequisites()) {
      for (final p in bo.getPrerequisiteList()) {
        if (!bEmpty) sb.write(',');
        sb.write(p.getDescription(shortForm));
        bEmpty = false;
      }
    }

    final String type = bo.getTypeString();
    if (type.isNotEmpty) {
      if (!shortForm) {
        if (!bEmpty) sb.write('|');
        sb.write('TYPE=');
        bEmpty = false;
      }
      if (!shortForm || sb.toString()[sb.length - 1] == '[') {
        sb.write(type);
        bEmpty = false;
      }
    }

    if (!bEmpty) sb.write('|');
    sb.write(_getSourceString(bo));
    sb.write(']');
    return sb.toString();
  }

  String _getSourceString(BonusObj bo) {
    final Object? source = _getSourceObject(bo);
    if (source == null) return 'NONE';
    if (source is PlayerCharacter) return source.getName();
    return source.toString();
  }

  Object? _getSourceObject(BonusObj bo) {
    Object? source = _activeBonusBySource[bo];
    if (source == null) {
      final TempBonusInfo? tbi = _tempBonusBySource[bo];
      if (tbi != null) {
        source = tbi.source;
      }
    }
    return source;
  }

  List<BonusPair> getStringListFromBonus(BonusObj bo) {
    final Object? creatorObj = _getSourceObject(bo);

    List<String> associatedList;
    if (creatorObj is CDOMObject) {
      final List<String>? assoc = pc.getConsolidatedAssociationList(creatorObj);
      associatedList = (assoc == null || assoc.isEmpty) ? _noAssocList : assoc;
    } else {
      associatedList = _noAssocList;
    }

    final List<BonusPair> bonusList = [];
    final String bonusName = bo.getBonusName();
    final List<String> bonusInfoArray = bo.getBonusInfo().split(',');
    final String bonusType = bo.getTypeString();

    for (final String assoc in associatedList) {
      String replacedName;
      if (bonusName.contains(_valueTokenReplacement)) {
        replacedName = bonusName.replaceAll(_valueTokenReplacement, assoc);
      } else {
        replacedName = bonusName;
      }

      final List<String> replacedInfoList = [];
      for (final String bonusInfo in bonusInfoArray) {
        if (bonusInfo.contains(_valueTokenReplacement)) {
          replacedInfoList.add(bonusInfo.replaceAll(_valueTokenReplacement, assoc));
        } else if (bonusInfo.contains(_varTokenReplacement)) {
          replacedInfoList.add(bonusName.replaceAll(_varTokenReplacement, assoc));
        } else if (bonusInfo == _listTokenReplacement) {
          replacedInfoList.add(assoc);
        } else {
          replacedInfoList.add(bonusInfo);
        }
      }

      dynamic newFormula;
      if (bo.isValueStatic()) {
        newFormula = bo.getFormula();
      } else {
        String value = bo.getValue();
        final int listIndex = value.indexOf(_valueTokenReplacement);
        String thisValue = value;
        if (listIndex >= 0) {
          thisValue = value.replaceAll(_valueTokenReplacement, assoc);
        }
        if (thisValue.isEmpty) thisValue = '0';
        newFormula = FormulaFactory.getFormulaFor(thisValue);
      }

      for (final String replacedInfo in replacedInfoList) {
        final StringBuffer sb = StringBuffer();
        sb.write('$replacedName.$replacedInfo');
        if (bo.hasTypeString()) {
          sb.write(':$bonusType');
        }
        bonusList.add(BonusPair(sb.toString(), newFormula, creatorObj));
      }
    }

    return bonusList;
  }

  double calcBonusesWithCost(Iterable<BonusObj> list) {
    double totalBonus = 0;
    for (final BonusObj aBonus in list) {
      final Object? anObj = _getSourceObject(aBonus);
      if (anObj == null) continue;

      double iBonus = 0;
      if (aBonus.qualifies(pc, anObj as CDOMObject)) {
        iBonus = aBonus.resolve(pc, (anObj as CDOMObject).getQualifiedKey()).toDouble();
      }

      int k;
      if (ChooseActivation.hasNewChooseToken(anObj as CDOMObject)) {
        k = 0;
        for (final String aString in pc.getConsolidatedAssociationList(anObj as CDOMObject) ?? []) {
          if (aString.toLowerCase() == aBonus.getBonusInfo().toLowerCase()) {
            k++;
          }
        }
      } else {
        k = 1;
      }

      if (k == 0 && !CoreUtility.doublesEqual(iBonus, 0)) {
        totalBonus += iBonus;
      } else {
        totalBonus += (iBonus * k);
      }
    }
    return totalBonus;
  }

  bool hasTempBonusesApplied(CDOMObject mod) {
    return _tempBonusBySource.values.any((tbi) => tbi.source == mod);
  }

  Map<BonusObj, Object> _getAllActiveBonuses() {
    final Map<BonusObj, Object> ret = {};
    for (final dynamic pobj in pc.getBonusContainerList()) {
      if (pobj == null || pobj is EquipmentModifier) continue;
      bool use = true;
      if (pobj is PCClass) {
        use = pc.getLevel(pobj) > 0;
      }
      if (use) {
        pobj.activateBonuses(pc);
        final List<BonusObj> abs = pobj.getActiveBonuses(pc) as List<BonusObj>;
        for (final BonusObj bo in abs) {
          ret[bo] = pobj;
        }
      }
    }
    if (pc.getUseTempMods()) {
      ret.addAll(_getTempBonuses());
    }
    return ret;
  }

  void logChangeFromCheckpoint() {
    if (_checkpointMap == null) return;
    final Map<String, String> addedMap = Map.from(_activeBonusMap);
    for (final entry in _checkpointMap!.entries) {
      if (addedMap[entry.key] == entry.value) {
        addedMap.remove(entry.key);
      }
    }
    final Map<String, String> removedMap = Map.from(_checkpointMap!);
    for (final entry in _activeBonusMap.entries) {
      if (removedMap[entry.key] == entry.value) {
        removedMap.remove(entry.key);
      }
    }
    // log: ..Bonuses removed last round: $removedMap
    // log: ..Bonuses added last round: $addedMap
  }
}
