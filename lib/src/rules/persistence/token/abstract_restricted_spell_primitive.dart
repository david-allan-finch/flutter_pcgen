// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractRestrictedSpellPrimitive

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/primitive_token.dart';

/// Abstract base for spell primitives that support optional level and known-only
/// restrictions (LEVELMIN=, LEVELMAX=, KNOWN=YES/NO).
///
/// Implements [PrimitiveToken] for [Spell]-typed objects.  The restriction is
/// parsed from a bracket-enclosed string (e.g. "[LEVELMAX=3;KNOWN=YES]") and
/// stored in a private [_Restriction] record.
///
/// TODO: The following Java types have not yet been ported:
///   - Spell (use dynamic for now)
///   - CDOMList<Spell>, CDOMReference<Spell>
///   - Formula (FormulaFactory.getFormulaFor)
///   - PlayerCharacter, PCClass, CharacterSpell
///   - PrimitiveFilter<Spell>: allow(PlayerCharacter, Spell)
///   - Converter<Spell,R>, getCollection(PlayerCharacter, Converter<Spell,R>)
///   - context.getReferenceContext().getCDOMAllReference(Spell)
///   - Globals.getDefaultSpellBook()
///
/// Mirrors Java: AbstractRestrictedSpellPrimitive
///   implements PrimitiveToken<Spell>, PrimitiveFilter<Spell>
abstract class AbstractRestrictedSpellPrimitive
    implements PrimitiveToken<dynamic> {
  // TODO: type to CDOMReference<Spell> once ported.
  dynamic _allSpells;

  _Restriction? _restriction;

  // ---------------------------------------------------------------------------
  // PrimitiveToken<Spell>
  // ---------------------------------------------------------------------------

  @override
  bool initialize(LoadContext context, Type cl, String? value, String? args) {
    // TODO: _allSpells = context.getReferenceContext().getCDOMAllReference(Spell);
    if (args != null) {
      _restriction = _parseRestriction(args);
      return _restriction != null;
    }
    return true;
  }

  @override
  Type getReferenceClass() {
    // TODO: return Spell once ported.
    return dynamic;
  }

  // ---------------------------------------------------------------------------
  // LST format
  // ---------------------------------------------------------------------------

  @override
  String getLSTformat([bool useAny = false]) => getPrimitiveLST().toString();

  /// Returns the LST representation of this primitive (without restriction).
  String getPrimitiveLST();

  // ---------------------------------------------------------------------------
  // Restriction helpers (public API mirrors Java)
  // ---------------------------------------------------------------------------

  bool hasRestriction() => _restriction != null;

  /// Returns the bracketed restriction string (e.g. "[LEVELMAX=3;KNOWN=YES]"),
  /// or an empty string when there is no restriction.
  String getRestrictionLST() {
    if (_restriction == null) return '';
    return '[${_restriction!.getLSTformat()}]';
  }

  /// Returns true if [spell] passes the restriction for the given [pc] at
  /// [level] with the given [source] and optional [optionalList].
  ///
  /// TODO: parameter types to (PlayerCharacter, int, String, Spell,
  ///       CDOMList<Spell>?) once ported.
  bool allowSpell(
      dynamic pc, int level, String source, dynamic spell, dynamic optionalList) {
    if (_restriction != null) {
      final r = _restriction!;
      // TODO: resolve r.maxLevel / r.minLevel Formula against pc
      if (r.maxLevel != null) {
        // Java: if (level > r.maxLevel.resolve(pc, source).intValue()) return false;
      }
      if (r.minLevel != null) {
        // Java: if (level < r.minLevel.resolve(pc, source).intValue()) return false;
      }
      if (r.knownRequired != null) {
        // TODO: check CharacterSpell presence across pc.getClassSet()
        throw UnimplementedError(
            'AbstractRestrictedSpellPrimitive.allowSpell: '
            'requires PlayerCharacter + CharacterSpell infrastructure');
      }
    }
    return true;
  }

  /// Returns true if [other] has the same restriction as this primitive.
  bool equalsRestrictedPrimitive(AbstractRestrictedSpellPrimitive other) {
    if (identical(this, other)) return true;
    if (_restriction == null) return other._restriction == null;
    return _restriction == other._restriction;
  }

  // ---------------------------------------------------------------------------
  // Collection / filter (stubs)
  // ---------------------------------------------------------------------------

  /// Returns the collection of spells matching this primitive for [pc].
  ///
  /// TODO: parameter types to (PlayerCharacter, Converter<Spell,R>) once ported.
  dynamic getCollection(dynamic pc, dynamic converter) {
    // Java: return c.convert(allSpells, this);
    throw UnimplementedError(
        'AbstractRestrictedSpellPrimitive.getCollection: '
        'requires Converter + CDOMReference infrastructure');
  }

  // ---------------------------------------------------------------------------
  // Private: parse restriction string
  // ---------------------------------------------------------------------------

  _Restriction? _parseRestriction(String restrString) {
    // TODO: Formula.isValid() check requires Formula infrastructure.
    // For now, perform a best-effort parse and defer formula validation.
    final parts = restrString.split(';');
    dynamic levelMax;
    dynamic levelMin;
    bool? known;

    for (final tok in parts) {
      if (tok.startsWith('LEVELMAX=')) {
        // TODO: levelMax = FormulaFactory.getFormulaFor(tok.substring(9));
        //       if (!levelMax.isValid()) return null;
        levelMax = tok.substring(9); // store raw string until Formula is ported
      } else if (tok.startsWith('LEVELMIN=')) {
        // TODO: levelMin = FormulaFactory.getFormulaFor(tok.substring(9));
        //       if (!levelMin.isValid()) return null;
        levelMin = tok.substring(9);
      } else if (tok == 'KNOWN=YES') {
        known = true;
      } else if (tok == 'KNOWN=NO') {
        known = false;
      } else {
        // TODO: log error via Logging.errorPrint once ported.
        return null;
      }
    }
    return _Restriction(levelMin, levelMax, known);
  }
}

// ---------------------------------------------------------------------------
// Internal value object for spell restrictions
// ---------------------------------------------------------------------------

class _Restriction {
  /// Minimum level formula (raw string until Formula is ported).
  // TODO: type to Formula once ported.
  final dynamic minLevel;

  /// Maximum level formula (raw string until Formula is ported).
  // TODO: type to Formula once ported.
  final dynamic maxLevel;

  final bool? knownRequired;

  const _Restriction(this.minLevel, this.maxLevel, this.knownRequired);

  String getLSTformat() {
    final sb = StringBuffer();
    if (knownRequired != null) {
      sb.write('KNOWN=');
      sb.write(knownRequired! ? 'YES' : 'NO');
    }
    if (maxLevel != null) {
      if (sb.isNotEmpty) sb.write(';');
      sb.write('LEVELMAX=');
      sb.write(maxLevel);
    }
    if (minLevel != null) {
      if (sb.isNotEmpty) sb.write(';');
      sb.write('LEVELMIN=');
      sb.write(minLevel);
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is _Restriction) {
      if (knownRequired != other.knownRequired) return false;
      if (maxLevel != other.maxLevel) return false;
      return minLevel == other.minLevel;
    }
    return false;
  }

  @override
  int get hashCode {
    return Object.hash(knownRequired, maxLevel, minLevel);
  }
}
