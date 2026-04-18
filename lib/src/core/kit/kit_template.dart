import '../../base/util/hash_map_to_list.dart';
import '../../cdom/base/cdom_single_ref.dart';
import '../kit.dart';
import '../pc_template.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitTemplate extends BaseKit {
  final HashMapToList<CDOMSingleRef<PCTemplate>, CDOMSingleRef<PCTemplate>> _templateList = HashMapToList();

  void addTemplate(CDOMSingleRef<PCTemplate> ref, List<CDOMSingleRef<PCTemplate>> subList) {
    _templateList.initializeListFor(ref);
    _templateList.addAllToListFor(ref, subList);
  }

  bool isEmpty() => _templateList.isEmpty;

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    final selectedMap = _buildSelectedTemplateMap(aPC);
    return selectedMap.isNotEmpty;
  }

  @override
  void apply(PlayerCharacter aPC) {
    final selectedMap = _buildSelectedTemplateMap(aPC);
    for (final entry in selectedMap.entries) {
      for (final subTemplate in entry.value) {
        aPC.setTemplatesAdded(entry.key, subTemplate);
      }
      aPC.addTemplate(entry.key);
    }
  }

  Map<PCTemplate, List<PCTemplate>> _buildSelectedTemplateMap(PlayerCharacter aPC) {
    final selectedMap = <PCTemplate, List<PCTemplate>>{};
    for (final ref in _templateList.getKeySet()) {
      final templateToAdd = ref.get();
      final subList = _templateList.getListFor(ref) ?? [];
      final subAdded = <PCTemplate>[];
      for (final subRef in subList) {
        final owned = subRef.get();
        subAdded.add(owned);
        aPC.setTemplatesAdded(templateToAdd, owned);
      }
      aPC.addTemplate(templateToAdd);
      selectedMap[templateToAdd] = subAdded;
    }
    return selectedMap;
  }

  @override
  String getObjectName() => 'Templates';

  @override
  String toString() {
    final parts = <String>[];
    for (final ref in _templateList.getKeySet()) {
      final buf = StringBuffer(ref.getLSTformat(false));
      final subList = _templateList.getListFor(ref);
      if (subList != null) {
        for (final subRef in subList) {
          buf.write('[TEMPLATE:${subRef.getLSTformat(false)}]');
        }
      }
      parts.add(buf.toString());
    }
    return parts.join('|');
  }
}
