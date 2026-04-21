// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractToFactToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'abstract_non_empty_token.dart';
import 'cdom_compatibility_token.dart';
import 'parse_result.dart';

/// Converts a simple String (formerly a StringKey-based token) into a FACT.
///
/// This is a compatibility token: it emits a deprecation warning and delegates
/// to the "FACT" token handler so old data files still load correctly.
///
/// [T] is the type of object on which this token operates.
///
/// Mirrors Java: AbstractToFactToken<T extends Loadable>
abstract class AbstractToFactToken<T> extends AbstractNonEmptyToken<T>
    implements CDOMCompatibilityToken<T> {
  @override
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value) {
    // TODO: emit deprecation log equivalent to Java's Logging.deprecationPrint.
    // Java: Logging.deprecationPrint(getTokenClass().getSimpleName() + " token "
    //   + getTokenName() + " has been deprecated and replaced by FACT. "
    //   + "Token was " + getTokenName() + ':' + value, context);

    // TODO: context.processToken requires CDOMToken dispatch infrastructure
    // (FactKey / FACT token handler). Wire up when that is ported.
    // Java: if (!context.processToken(obj, "FACT", getTokenName() + '|' + value))
    //         return new ParseResult.Fail("Delegation Error to FACT");
    throw UnimplementedError(
        'AbstractToFactToken.parseNonEmptyToken: '
        'requires context.processToken + FactKey infrastructure');
  }

  @override
  int compatibilityLevel() => 6;

  @override
  int compatibilitySubLevel() => 4;

  @override
  int compatibilityPriority() => 0;
}
