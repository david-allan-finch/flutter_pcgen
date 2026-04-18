// Translation of pcgen.core.Domain

import '../cdom/enumeration/formula_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import 'pcobject.dart';

/// Represents a divine domain (e.g., Fire, War, Protection).
///
/// Domains can grant bonus spells, special abilities, and feat choices
/// to divine casters who select them.
final class Domain extends PObject {
  String getLocalScopeName() => 'PC.DOMAIN';

  /// Returns the CHOOSE formula, if any (for domain-granted choices).
  dynamic getChooseInfo() =>
      getSafe(ObjectKey.getConstant<dynamic>('CHOOSE_INFO'));

  /// Returns the SELECT formula used by CHOOSE processing.
  dynamic getSelectFormula() =>
      getSafe(ObjectKey.getConstant<dynamic>('SELECT'));

  /// Returns the CHOOSE actors list.
  List<dynamic> getActors() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('NEW_CHOOSE_ACTOR'));

  /// Returns the formula source string used by the formula engine.
  String getFormulaSource() => getKeyName();

  /// Returns the NUM_CHOICES formula.
  dynamic getNumChoices() =>
      getSafe(ObjectKey.getConstant<dynamic>('NUM_CHOICES'));
}
