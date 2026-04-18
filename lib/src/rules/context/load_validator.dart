import '../../base/util/hash_map_to_list.dart';
import '../../cdom/base/class_identity.dart';
import '../../cdom/reference/qualifier.dart';
import '../../cdom/reference/unconstructed_validator.dart';
import '../../core/campaign.dart';

class LoadValidator implements UnconstructedValidator {
  final List<dynamic> _campaignList; // List<Campaign>
  HashMapToList<String, String>? _simpleMap;

  LoadValidator(List<dynamic> campaigns) : _campaignList = List.of(campaigns);

  @override
  bool allowUnconstructed(ClassIdentity<dynamic> cl, String s) {
    _simpleMap ??= _buildSimpleMap();
    final list = _simpleMap!.getListFor(cl.getPersistentFormat());
    if (list != null) {
      for (final key in list) {
        if (key.toLowerCase() == s.toLowerCase()) {
          return true;
        }
      }
    }
    return false;
  }

  HashMapToList<String, String> _buildSimpleMap() {
    final map = HashMapToList<String, String>();
    for (final c in _campaignList) {
      final forwardRefs = (c as dynamic).getSafeListFor('FORWARDREF') as List;
      for (final q in forwardRefs) {
        final qRef = (q as dynamic).getQualifiedReference();
        map.addToListFor(
          qRef.getPersistentFormat() as String,
          qRef.getLSTformat(false) as String,
        );
      }
    }
    return map;
  }

  @override
  bool allowDuplicates(Type cl) {
    for (final c in _campaignList) {
      if ((c as dynamic).containsInList('DUPES_ALLOWED', cl) == true) {
        return true;
      }
    }
    return false;
  }
}
