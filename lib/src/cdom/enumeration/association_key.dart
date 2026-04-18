import '../base/cdom_object.dart';
import '../content/ability_category.dart';
import '../../base/formula/formula.dart';
import '../reference/cdom_single_ref.dart';
import 'nature.dart';
import 'skill_cost.dart';

// Type-safe key for use with AssociatedObject; each constant identifies the
// type of value stored under that key.
final class AssociationKey<T> {
  static final Map<String, AssociationKey<dynamic>> _map = {};

  // Load (Context) items
  static final AssociationKey<CdomObject> owner = AssociationKey._('OWNER');
  static final AssociationKey<String> token = AssociationKey._('TOKEN');

  // Token relationship items
  static final AssociationKey<SkillCost> skillCost = AssociationKey._('SKILL_COST');
  static final AssociationKey<int> spellLevel = AssociationKey._('SPELL_LEVEL');
  static final AssociationKey<bool> known = AssociationKey._('KNOWN');
  static final AssociationKey<List<String>> assocChoices = AssociationKey._('ASSOC_CHOICES');
  static final AssociationKey<Nature> nature = AssociationKey._('NATURE');
  static final AssociationKey<CdomSingleRef<AbilityCategory>> category = AssociationKey._('CATEGORY');
  static final AssociationKey<String> casterLevel = AssociationKey._('CASTER_LEVEL');
  static final AssociationKey<Formula> timesPerUnit = AssociationKey._('TIMES_PER_UNIT');
  static final AssociationKey<String> timeUnit = AssociationKey._('TIME_UNIT');
  static final AssociationKey<String> spellbook = AssociationKey._('SPELLBOOK');
  static final AssociationKey<String> dcFormula = AssociationKey._('DC_FORMULA');

  // Player Character items
  static final AssociationKey<String> specialty = AssociationKey._('SPECIALTY');

  final String _name;

  AssociationKey._(this._name) {
    _map[_name.toLowerCase()] = this;
  }

  static AssociationKey<OT> getKeyFor<OT>(String assocName) {
    final key = _map[assocName.toLowerCase()];
    if (key != null) return key as AssociationKey<OT>;
    final newKey = AssociationKey<OT>._(assocName.toUpperCase());
    return newKey;
  }

  T cast(Object obj) => obj as T;

  @override
  String toString() {
    return _map.entries
        .where((e) => e.value == this)
        .map((e) => e.key.toUpperCase())
        .firstOrNull ?? '';
  }
}
