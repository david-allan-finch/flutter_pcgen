import '../../cdom/base/cdom_reference.dart';
import '../../cdom/content/cn_ability.dart';
import '../../cdom/content/cn_ability_factory.dart';
import '../../cdom/enumeration/nature.dart';
import '../../cdom/helper/cn_ability_selection.dart';
import '../../cdom/reference/cdom_single_ref.dart';
import '../../core/ability.dart';
import '../../core/ability_category.dart';
import '../../core/kit.dart';
import '../../core/player_character.dart';
import 'base_kit.dart';

// Kit task that grants abilities to a PC.
final class KitAbilities extends BaseKit {
  bool? free;
  int? choiceCount;
  final List<CdomReference<Ability>> _abilities = [];
  CdomSingleRef<AbilityCategory>? catRef;

  // Transient state
  List<CnAbilitySelection>? _abilitiesToAdd;

  void setFree(bool argFree) { free = argFree; }
  bool isFree() => free == true;
  bool? getFree() => free;

  void setCount(int quan) { choiceCount = quan; }
  int? getCount() => choiceCount;
  int getSafeCount() => choiceCount ?? 1;

  void addAbility(CdomReference<Ability> ref) { _abilities.add(ref); }
  List<CdomReference<Ability>> getAbilityKeys() => List.unmodifiable(_abilities);

  void setCategory(CdomSingleRef<AbilityCategory> ac) { catRef = ac; }
  CdomSingleRef<AbilityCategory>? getCategory() => catRef;

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _abilitiesToAdd = [];
    double minCost = double.maxFinite;
    final available = <_AbilitySelection>[];

    for (final ref in _abilities) {
      final choice = ref.getChoice();
      for (final a in ref.getContainedObjects()) {
        if (a == null) {
          warnings.add('ABILITY: $ref could not be found.');
          minCost = 0;
          continue;
        }
        if (a.getCost() < minCost) minCost = a.getCost();
        if (choice == null && a.getSafe(null) == true) {
          available.add(_AbilitySelection(a, ''));
        } else {
          available.add(_AbilitySelection(a, choice));
        }
      }
    }

    int numberOfChoices = getSafeCount();
    if (numberOfChoices > available.length) numberOfChoices = available.length;

    final AbilityCategory category = catRef!.get();
    bool tooManyAbilities = false;
    int maxChoices = minCost > 0.0
        ? (aPC.getAvailableAbilityPool(category) / minCost).toInt()
        : numberOfChoices;
    if (!isFree() && numberOfChoices > maxChoices) {
      numberOfChoices = maxChoices;
      tooManyAbilities = true;
    }
    if (!isFree() && numberOfChoices == 0) {
      warnings.add('ABILITY: Not enough ${category.getPluralName()} available to take "$this"');
      return false;
    }

    List<_AbilitySelection> selected;
    if (numberOfChoices == available.length) {
      selected = available;
    } else {
      selected = available.take(numberOfChoices).toList();
    }

    for (final as_ in selected) {
      final ability = as_.ability;
      if (isFree()) {
        aPC.adjustAbilities(category, 1.0);
      }
      if (ability.getCost() > aPC.getAvailableAbilityPool(category)) {
        tooManyAbilities = true;
      } else {
        final cna = CnAbilityFactory.getCNAbility(category, Nature.normal, ability);
        final cnas = CnAbilitySelection(cna, as_.selection);
        _abilitiesToAdd!.add(cnas);
        aPC.addAbility(cnas, null, this);
      }
    }

    if (tooManyAbilities) {
      warnings.add('ABILITY: Some Abilities were not granted -- not enough remaining feats');
      return false;
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    for (final cnas in _abilitiesToAdd!) {
      aPC.addAbility(cnas, null, null);
      if (isFree()) {
        aPC.adjustAbilities(catRef!.get(), 1.0);
      }
    }
  }

  @override
  String getObjectName() => 'Abilities';

  @override
  String toString() {
    final sb = StringBuffer();
    if (choiceCount != null || _abilities.length != 1) {
      sb.write('${getSafeCount()} of ');
    }
    bool firstDone = false;
    for (final ref in _abilities) {
      if (firstDone) sb.write('; ');
      firstDone = true;
      final choice = ref.getChoice();
      for (final a in ref.getContainedObjects()) {
        if (a != null) {
          sb.write(a.getKeyName());
          if (choice != null) {
            sb.write(' ($choice)');
          }
        }
      }
    }
    if (isFree()) sb.write(' (free)');
    return sb.toString();
  }
}

class _AbilitySelection implements Comparable<_AbilitySelection> {
  final Ability ability;
  final String? selection;

  _AbilitySelection(this.ability, this.selection);

  @override
  String toString() {
    final sb = StringBuffer(ability.getDisplayName());
    if (selection != null) sb.write(' ($selection)');
    return sb.toString();
  }

  @override
  int compareTo(_AbilitySelection o) {
    final base = ability.compareTo(o.ability);
    if (base != 0) return base;
    if (selection == null) return o.selection == null ? 0 : -1;
    if (o.selection == null) return 1;
    return selection!.toLowerCase().compareTo(o.selection!.toLowerCase());
  }
}
