// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractQualifiedChooseToken

import '../../../rules/context/load_context.dart';
import 'abstract_token_with_separator.dart';
import 'cdom_secondary_token.dart';
import 'parse_result.dart';

/// Abstract base for CHOOSE sub-tokens that operate on CDOMObject-typed
/// collections using a [ReferenceManufacturer], and support an optional
/// TITLE= suffix.
///
/// The concrete subtype [T] (a CDOMObject) is the element type being chosen.
/// This token always registers itself under the "CHOOSE" parent token.
///
/// Responsibilities of subclasses:
///   - [getTokenName] – the CHOOSE sub-token keyword (e.g. "FEAT").
///   - [getPersistentFormat] – format identifier stored with ChooseInfo.
///   - [getDefaultTitle] – title shown in the chooser UI when none specified.
///   - [getListKey] – the AssociationListKey used to track chosen items.
///   - Choice lifecycle methods: [applyChoice], [removeChoice], [restoreChoice],
///     [getCurrentlySelected], [allow].
///
/// TODO: The following Java types have not yet been ported:
///   - CDOMObject, CDOMSecondaryToken<CDOMObject> (use dynamic)
///   - ReferenceManufacturer<T>
///   - PrimitiveCollection<T>, PrimitiveChoiceSet<T>, CollectionToChoiceSet
///   - BasicChooseInformation<T>, ChooseInformation<T>
///   - ObjectKey.CHOOSE_INFO, AssociationListKey<T>
///   - GroupingState
///   - PlayerCharacter, ChooseDriver, ChooseSelectionActor
///   - context.getChoiceSet / context.getObjectContext
///
/// Mirrors Java: AbstractQualifiedChooseToken<T extends CDOMObject>
///   extends AbstractTokenWithSeparator<CDOMObject>
///   implements CDOMSecondaryToken<CDOMObject>, Chooser<T>
abstract class AbstractQualifiedChooseToken<T>
    extends AbstractTokenWithSeparator<dynamic>
    implements CDOMSecondaryToken<dynamic> {
  // ---------------------------------------------------------------------------
  // CDOMSubToken
  // ---------------------------------------------------------------------------

  @override
  String getParentToken() => 'CHOOSE';

  // ---------------------------------------------------------------------------
  // AbstractTokenWithSeparator
  // ---------------------------------------------------------------------------

  @override
  String separator() => '|';

  @override
  ParseResult parseTokenWithSeparator(
      LoadContext context, dynamic obj, String value) {
    // Delegate to the overload that also accepts a ReferenceManufacturer.
    // Concrete subclasses should call getManufacturer(context) themselves.
    // TODO: implement once ReferenceManufacturer + ChooseInformation are ported.
    throw UnimplementedError(
        'AbstractQualifiedChooseToken.parseTokenWithSeparator: '
        'requires ReferenceManufacturer + ChooseInformation infrastructure');
  }

  /// Core parse logic that accepts an explicit [rm] (ReferenceManufacturer).
  ///
  /// Handles optional TITLE= suffix, then builds a [PrimitiveChoiceSet] and
  /// stores a [BasicChooseInformation] on [obj] via the object context.
  ///
  /// TODO: parameter type [rm] to ReferenceManufacturer<T> once ported.
  ParseResult parseTokenWithSeparatorAndManufacturer(
      LoadContext context, dynamic rm, dynamic obj, String value) {
    // TODO: implement once PrimitiveCollection + ChooseInformation ported.
    // Java logic (summarised):
    //   1. Find last '|'; if it exists and next part starts with "TITLE=", split.
    //   2. context.getChoiceSet(rm, activeValue) → PrimitiveCollection<T>
    //   3. Validate groupingState.isValid()
    //   4. Build CollectionToChoiceSet, BasicChooseInformation, store via
    //      context.getObjectContext().put(obj, ObjectKey.CHOOSE_INFO, tc)
    throw UnimplementedError(
        'AbstractQualifiedChooseToken.parseTokenWithSeparatorAndManufacturer: '
        'requires PrimitiveCollection + ChooseInformation infrastructure');
  }

  // ---------------------------------------------------------------------------
  // CDOMToken<CDOMObject>
  // ---------------------------------------------------------------------------

  @override
  Type getTokenClass() {
    // TODO: return CDOMObject once ported.
    return dynamic;
  }

  // ---------------------------------------------------------------------------
  // CDOMSecondaryToken unparse
  // ---------------------------------------------------------------------------

  @override
  List<String>? unparse(LoadContext context, dynamic cdo) {
    // TODO: implement once ObjectKey.CHOOSE_INFO + ChooseInformation are ported.
    // Java logic:
    //   ChooseInformation<?> tc = context.getObjectContext().getObject(cdo, ObjectKey.CHOOSE_INFO);
    //   if (tc == null || !tc.getName().equals(getTokenName())) return null;
    //   Validate groupingState; build LST format; append TITLE= if non-default.
    throw UnimplementedError(
        'AbstractQualifiedChooseToken.unparse: '
        'requires ObjectKey.CHOOSE_INFO + ChooseInformation infrastructure');
  }

  // ---------------------------------------------------------------------------
  // Chooser<T> lifecycle (stubs; implement once PlayerCharacter is ported)
  // ---------------------------------------------------------------------------

  /// Apply [choice] to [pc] when the user makes a selection.
  /// TODO: parameter types to (ChooseDriver, T, PlayerCharacter) once ported.
  void applyChoice(dynamic owner, T choice, dynamic pc) {
    restoreChoice(pc, owner, choice);
  }

  /// Remove a previously applied [choice] from [pc].
  /// TODO: parameter types to (PlayerCharacter, ChooseDriver, T) once ported.
  void removeChoice(dynamic pc, dynamic owner, T choice) {
    // TODO: pc.removeAssoc(owner, getListKey(), choice);
    //       iterate owner.getActors() and call ca.removeChoice(owner, choice, pc)
    throw UnimplementedError(
        'AbstractQualifiedChooseToken.removeChoice: requires PlayerCharacter');
  }

  /// Restore a previously saved [choice] to [pc].
  /// TODO: parameter types to (PlayerCharacter, ChooseDriver, T) once ported.
  void restoreChoice(dynamic pc, dynamic owner, T choice) {
    // TODO: pc.addAssoc(owner, getListKey(), choice);
    //       iterate owner.getActors() and call ca.applyChoice(owner, choice, pc)
    throw UnimplementedError(
        'AbstractQualifiedChooseToken.restoreChoice: requires PlayerCharacter');
  }

  /// Returns the currently selected items for [owner] on [pc].
  /// TODO: parameter types to (ChooseDriver, PlayerCharacter) once ported.
  List<T> getCurrentlySelected(dynamic owner, dynamic pc) {
    // TODO: return pc.getAssocList(owner, getListKey());
    throw UnimplementedError(
        'AbstractQualifiedChooseToken.getCurrentlySelected: '
        'requires PlayerCharacter');
  }

  /// Always returns true – filtering is handled at ChoiceSet build time.
  /// TODO: parameter types to (T, PlayerCharacter, bool) once ported.
  bool allow(T choice, dynamic pc, bool allowStack) => true;

  // ---------------------------------------------------------------------------
  // Abstract accessors for subclasses
  // ---------------------------------------------------------------------------

  /// Format identifier stored in [BasicChooseInformation] (e.g. "FEAT").
  String getPersistentFormat();

  /// Default title shown in the chooser UI (e.g. "Choose a Feat").
  String getDefaultTitle();

  /// The [AssociationListKey] used to track selected items on a character.
  ///
  /// TODO: type to AssociationListKey<T> once ported.
  dynamic getListKey();
}
