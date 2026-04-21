// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractToFactSetToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/abstract_non_empty_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/cdom_compatibility_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/parse_result.dart';

/// Converts a list (formerly a ListKey-based token) into a FACTSET.
///
/// This is a compatibility token: it delegates to the "FACTSET" token handler
/// so old data files that used list-storing tokens still load correctly.
///
/// [T] is the type of object on which this token operates.
///
/// Mirrors Java: AbstractToFactSetToken<T extends Loadable>
abstract class AbstractToFactSetToken<T> extends AbstractNonEmptyToken<T>
    implements CDOMCompatibilityToken<T> {
  @override
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value) {
    // TODO: context.processToken requires CDOMToken dispatch infrastructure
    // (FactSetKey / FACTSET token handler). Wire up when that is ported.
    // Java: if (!context.processToken(obj, "FACTSET", getTokenName() + '|' + value))
    //         return new ParseResult.Fail("Delegation Error to FACTSET");
    throw UnimplementedError(
        'AbstractToFactSetToken.parseNonEmptyToken: '
        'requires context.processToken + FactSetKey infrastructure');
  }

  @override
  int compatibilityLevel() => 6;

  @override
  int compatibilitySubLevel() => 4;

  @override
  int compatibilityPriority() => 0;
}
