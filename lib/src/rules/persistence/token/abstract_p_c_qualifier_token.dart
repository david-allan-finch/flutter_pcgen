// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractPCQualifierToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'qualifier_token.dart';

/// A [QualifierToken] that implements the "PC" qualifier for a specific type of
/// target object.
///
/// When used in a CHOOSE expression, a PC qualifier selects items that the
/// current player-character already possesses (as determined by [getPossessed]).
/// An optional value string restricts the set further via a primitive choice
/// filter; without a value, all references are included.
///
/// The token optionally supports negation (prefix "!" in LST).
///
/// [T] is the CDOMObject subtype this qualifier operates on.
///
/// TODO: The following Java types have not yet been ported:
///   - CDOMObject (use dynamic for now)
///   - PrimitiveCollection<T>
///   - SelectionCreator<T>
///   - GroupingState
///   - Converter<T,R> / AddFilterConverter / NegateFilterConverter
///   - PlayerCharacter
///   - context.getPrimitiveChoiceFilter / sc.getAllReference / sc.getReferenceClass
///
/// Mirrors Java: AbstractPCQualifierToken<T extends CDOMObject>
///   implements QualifierToken<T>, PrimitiveFilter<T>
abstract class AbstractPCQualifierToken<T> implements QualifierToken<T> {
  // TODO: type to Type (Class<T>) once CDOMObject hierarchy is ported.
  Type? _refClass;

  // TODO: type to PrimitiveCollection<T> once ported.
  dynamic _pcs;

  bool _wasRestricted = false;
  bool _negated = false;

  @override
  String getTokenName() => 'PC';

  @override
  bool initialize(
    LoadContext context,
    dynamic selectionCreator, // TODO: SelectionCreator<T>
    String? condition,
    String? value,
    bool negated,
  ) {
    if (condition != null) {
      // TODO: log error via Logging.addParseMessage once ported.
      // Java: Logging.addParseMessage(Level.SEVERE,
      //   "Cannot make " + getTokenName() + " into a conditional Qualifier, remove =");
      return false;
    }
    if (selectionCreator == null) {
      throw ArgumentError('selectionCreator must not be null');
    }
    // TODO: _refClass = selectionCreator.getReferenceClass();
    _negated = negated;
    if (value == null) {
      // TODO: _pcs = selectionCreator.getAllReference();
    } else {
      // TODO: _pcs = context.getPrimitiveChoiceFilter(selectionCreator, value);
      _wasRestricted = true;
    }
    // TODO: return _pcs != null;
    throw UnimplementedError(
        'AbstractPCQualifierToken.initialize: '
        'requires SelectionCreator + PrimitiveCollection infrastructure');
  }

  @override
  Type getReferenceClass() {
    // TODO: return _refClass once properly typed.
    return dynamic;
  }

  /// Returns the items of type [T] possessed by the given player-character.
  ///
  /// TODO: parameter type to PlayerCharacter once ported.
  List<T> getPossessed(dynamic pc);

  /// Returns the LST representation of this qualifier.
  String getLSTformat(bool useAny) {
    final sb = StringBuffer();
    if (_negated) sb.write('!');
    sb.write(getTokenName());
    if (_wasRestricted) {
      // TODO: sb.write('['); sb.write(_pcs.getLSTformat(useAny)); sb.write(']');
    }
    return sb.toString();
  }

  // ---------------------------------------------------------------------------
  // Object identity
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (other is AbstractPCQualifierToken) {
      if (_pcs != other._pcs) return false;
      if (_refClass != other._refClass) return false;
      if (_refClass == null && runtimeType != other.runtimeType) return false;
      return _negated == other._negated;
    }
    return false;
  }

  @override
  int get hashCode => _pcs?.hashCode ?? 0;

  // ---------------------------------------------------------------------------
  // GroupingState / Collection helpers (stubs)
  // ---------------------------------------------------------------------------

  /// TODO: return GroupingState once ported.
  dynamic getGroupingState() {
    // Java: GroupingState gs = pcs == null ? GroupingState.ANY : pcs.getGroupingState().reduce();
    //       return negated ? gs.negate() : gs;
    throw UnimplementedError(
        'AbstractPCQualifierToken.getGroupingState: requires GroupingState');
  }

  /// Returns the collection of matching items for this qualifier.
  ///
  /// TODO: parameter/return types to Converter<T,R> once ported.
  dynamic getCollection(dynamic pc, dynamic converter) {
    // Java: conv = negated ? new NegateFilterConverter<>(conv) : conv;
    //       conv = new AddFilterConverter<>(conv, this);
    //       return pcs.getCollection(pc, conv);
    throw UnimplementedError(
        'AbstractPCQualifierToken.getCollection: '
        'requires Converter / PrimitiveCollection infrastructure');
  }

  /// Returns true if [po] is in the set possessed by [pc].
  bool allow(dynamic pc, T po) => getPossessed(pc).contains(po);
}
