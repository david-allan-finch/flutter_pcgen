// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.ClassWrappedToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'cdom_compatibility_token.dart';
import 'cdom_token.dart';
import 'parse_result.dart';

/// Provides compatibility for CLASS tokens used on CLASSLEVEL lines.
///
/// In PCGen data files up to 5.14 many CLASS tokens inadvertently appeared on
/// CLASSLEVEL lines. This wrapper allows them to be processed on level-1 lines
/// (where they are semantically equivalent to a CLASS line), while rejecting
/// them on any other level.  SubClass / SubstitutionClass parents are also
/// rejected because the delegation semantics are too ambiguous there.
///
/// Each instance gets a unique, monotonically increasing [compatibilityPriority]
/// so the loader can order competing wrappers deterministically.
///
/// TODO: The [parseToken] body references PCClassLevel, PCClass, SubClass, and
/// SubstitutionClass (and their IntegerKey / ObjectKey lookups) which have not
/// yet been ported to Dart.  Replace the [UnimplementedError] stubs once those
/// classes are available.
///
/// Mirrors Java: ClassWrappedToken implements CDOMCompatibilityToken<PCClassLevel>
class ClassWrappedToken implements CDOMCompatibilityToken<dynamic> {
  // Monotonically-increasing index shared across all instances (mirrors Java's
  // static wrapIndex field initialised to Integer.MIN_VALUE).
  static int _wrapIndex = -2147483648; // Integer.MIN_VALUE

  /// The CDOMToken<PCClass> that this wrapper delegates to.
  // TODO: type to CDOMToken<PCClass> once PCClass is ported.
  final CDOMToken<dynamic> wrappedToken;

  final int _priority;

  ClassWrappedToken(this.wrappedToken) : _priority = _wrapIndex++;

  // ---------------------------------------------------------------------------
  // CDOMToken<PCClassLevel>
  // ---------------------------------------------------------------------------

  @override
  Type getTokenClass() {
    // TODO: return PCClassLevel once ported.
    return dynamic;
  }

  @override
  ParseResult parseToken(LoadContext context, dynamic obj, String value) {
    // TODO: implement using PCClassLevel.get(IntegerKey.LEVEL),
    // ObjectKey.TOKEN_PARENT, SubClass, SubstitutionClass once ported.
    //
    // Java logic:
    //   if (ONE.equals(obj.get(IntegerKey.LEVEL))) {
    //     PCClass parent = (PCClass) obj.get(ObjectKey.TOKEN_PARENT);
    //     if (parent instanceof SubClass || parent instanceof SubstitutionClass)
    //       return ParseResult.Fail("Data used token: " + value + " …");
    //     return wrappedToken.parseToken(context, parent, value);
    //   }
    //   return ParseResult.Fail("Data used token: " + value
    //       + " … but it was used in a class level line other than level 1");
    throw UnimplementedError(
        'ClassWrappedToken.parseToken: '
        'requires PCClassLevel / PCClass / SubClass infrastructure');
  }

  @override
  String getTokenName() => wrappedToken.getTokenName();

  // ---------------------------------------------------------------------------
  // CompatibilityToken
  // ---------------------------------------------------------------------------

  @override
  int compatibilityLevel() => 5;

  @override
  int compatibilitySubLevel() => 14;

  @override
  int compatibilityPriority() => _priority;
}
