// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractSimpleChooseToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/abstract_token_with_separator.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/cdom_secondary_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/parse_result.dart';

/// Abstract base for simple CHOOSE sub-tokens whose element type [T] is a
/// [Loadable] (but not necessarily a full CDOMObject).
///
/// "Simple" means the choice set is built from a flat list of references
/// separated by '|' (or the keyword ALL), without requiring a
/// [ReferenceManufacturer] argument to the main parse method.
///
/// Subclasses must implement:
///   - [getTokenName] – the CHOOSE sub-token keyword.
///   - [getChooseClass] – the runtime [Type] (mirrors Java's Class<T>).
///   - [getDefaultTitle] – title shown in the chooser UI.
///   - [getListKey] – the AssociationListKey used to track choices.
///
/// [getPersistentFormat] is derived automatically from [getChooseClass].
///
/// TODO: The following Java types have not yet been ported:
///   - CDOMObject (use dynamic)
///   - CDOMGroupRef<T>, ReferenceManufacturer<T>, SelectionCreator<T>
///   - PrimitiveCollection<T>, CompoundOrPrimitive<T>
///   - PrimitiveChoiceSet<T>, CollectionToChoiceSet
///   - BasicChooseInformation<T>, ChooseInformation<T>
///   - CDOMObjectKey.CHOOSE_INFO, AssociationListKey<T>
///   - GroupingState, Constants.LST_ALL
///   - PlayerCharacter, ChooseDriver, ChooseSelectionActor
///   - context.getReferenceContext().getCDOMAllReference / getManufacturer
///   - ChoiceSetLoadUtilities.getSimplePrimitive
///
/// Mirrors Java: AbstractSimpleChooseToken<T extends Loadable>
///   extends AbstractTokenWithSeparator<CDOMObject>
///   implements CDOMSecondaryToken<CDOMObject>, Chooser<T>
abstract class AbstractSimpleChooseToken<T>
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
    // TODO: implement once CDOMGroupRef + ChooseInformation are ported.
    // Java logic (summarised):
    //   1. Find last '|'; if next part starts with "TITLE=", split and extract title.
    //   2. If activeValue == "ALL" → prim = allReference.
    //   3. Else: tokenise by '|', resolve each via
    //      ChoiceSetLoadUtilities.getSimplePrimitive → collect into Set, wrap in
    //      CompoundOrPrimitive.
    //   4. Validate groupingState.isValid().
    //   5. Build CollectionToChoiceSet, BasicChooseInformation, store via
    //      context.getObjectContext().put(obj, CDOMObjectKey.CHOOSE_INFO, tc).
    throw UnimplementedError(
        'AbstractSimpleChooseToken.parseTokenWithSeparator: '
        'requires CDOMGroupRef + ChooseInformation infrastructure');
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
    // TODO: implement once CDOMObjectKey.CHOOSE_INFO + ChooseInformation are ported.
    // Java logic:
    //   ChooseInformation<?> tc = context.getObjectContext().getObject(cdo, CDOMObjectKey.CHOOSE_INFO);
    //   if (tc == null || !tc.getName().equals(getTokenName())) return null;
    //   Validate groupingState; build LST; append TITLE= if non-default.
    throw UnimplementedError(
        'AbstractSimpleChooseToken.unparse: '
        'requires CDOMObjectKey.CHOOSE_INFO + ChooseInformation infrastructure');
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
    //       iterate owner.getActors() and call ca.removeChoice
    throw UnimplementedError(
        'AbstractSimpleChooseToken.removeChoice: requires PlayerCharacter');
  }

  /// Restore a previously saved [choice] to [pc].
  /// TODO: parameter types to (PlayerCharacter, ChooseDriver, T) once ported.
  void restoreChoice(dynamic pc, dynamic owner, T choice) {
    // TODO: pc.addAssoc(owner, getListKey(), choice);
    //       iterate owner.getActors() and call ca.applyChoice
    throw UnimplementedError(
        'AbstractSimpleChooseToken.restoreChoice: requires PlayerCharacter');
  }

  /// Returns the currently selected items for [owner] on [pc].
  /// TODO: parameter types to (ChooseDriver, PlayerCharacter) once ported.
  List<T> getCurrentlySelected(dynamic owner, dynamic pc) {
    // TODO: return pc.getAssocList(owner, getListKey());
    throw UnimplementedError(
        'AbstractSimpleChooseToken.getCurrentlySelected: '
        'requires PlayerCharacter');
  }

  /// Always returns true – filtering is done at ChoiceSet build time.
  bool allow(T choice, dynamic pc, bool allowStack) => true;

  // ---------------------------------------------------------------------------
  // Encode / decode (mirrors Chooser<T>)
  // ---------------------------------------------------------------------------

  /// Decodes an encoded string [s] back to a [T] instance.
  ///
  /// TODO: implement via context.getReferenceContext().silentlyGetConstructedCDOMObject
  T? decodeChoice(LoadContext context, String s) {
    // Java: return context.getReferenceContext()
    //              .silentlyGetConstructedCDOMObject(getChooseClass(), s);
    throw UnimplementedError(
        'AbstractSimpleChooseToken.decodeChoice: requires ReferenceContext');
  }

  /// Encodes [choice] as a string (its key name).
  ///
  /// TODO: implement once Loadable.getKeyName() is ported.
  String encodeChoice(T choice) {
    // Java: return choice.getKeyName();
    throw UnimplementedError(
        'AbstractSimpleChooseToken.encodeChoice: requires Loadable.getKeyName()');
  }

  // ---------------------------------------------------------------------------
  // Abstract accessors for subclasses
  // ---------------------------------------------------------------------------

  /// The runtime [Type] of elements this token selects.
  ///
  /// Mirrors Java's abstract Class<T> getChooseClass().
  Type getChooseClass();

  /// Format identifier derived from [getChooseClass] (upper-cased simple name).
  ///
  /// This is final in Java but Dart doesn't enforce that here.
  String getPersistentFormat() => getChooseClass().toString().toUpperCase();

  /// Default title shown in the chooser UI.
  String getDefaultTitle();

  /// The [AssociationListKey] used to track selected items on a character.
  ///
  /// TODO: type to AssociationListKey<T> once ported.
  dynamic getListKey();

  /// Returns a [SelectionCreator] for this token's choose class.
  ///
  /// TODO: return type to SelectionCreator<T> once ported.
  dynamic getManufacturer(LoadContext context) {
    // Java: return context.getReferenceContext().getManufacturer(getChooseClass());
    throw UnimplementedError(
        'AbstractSimpleChooseToken.getManufacturer: requires ReferenceContext');
  }
}
