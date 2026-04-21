// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.PreCompatibilityToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'cdom_primary_token.dart';
import 'cdom_secondary_token.dart';
import 'parse_result.dart';

/// Handles legacy PRExxx token format, converting it to modern Prerequisite
/// objects.
///
/// A [PreCompatibilityToken] wraps a low-level prerequisite parser
/// (the Dart equivalent of Java's [PrerequisiteParserInterface]) and exposes
/// it as both a primary and secondary CDOMToken that operates on objects
/// which can hold prerequisites (the Dart equivalent of
/// [ConcretePrereqObject]).
///
/// When [invert] is true the token name gets a leading "!" so that, e.g.,
/// "PRESPELL" becomes "!PRESPELL".
///
/// TODO: the following Java infrastructure has not yet been ported and is
/// indicated with stubs:
///   - ConcretePrereqObject (use dynamic for now)
///   - PrerequisiteParserInterface
///   - PrerequisiteWriterFactory / PrerequisiteWriterInterface
///   - context.getObjectContext().put(obj, prerequisite)
///   - context.getObjectContext().getPrerequisiteChanges(obj)
///
/// Mirrors Java: PreCompatibilityToken implements
///   CDOMPrimaryToken<ConcretePrereqObject>, CDOMSecondaryToken<ConcretePrereqObject>
class PreCompatibilityToken
    implements CDOMPrimaryToken<dynamic>, CDOMSecondaryToken<dynamic> {
  final String _tokenRoot;
  final String _tokenName;

  /// The low-level parser that converts the raw PRExxx value string.
  // TODO: type to PrerequisiteParserInterface once ported.
  final dynamic _prereqParser;

  final bool _invert;

  PreCompatibilityToken(String root, dynamic prereqParser, bool invert)
      : _tokenRoot = root.toUpperCase(),
        _prereqParser = prereqParser,
        _invert = invert,
        _tokenName = '${invert ? '!' : ''}PRE${root.toUpperCase()}';

  // ---------------------------------------------------------------------------
  // LstToken
  // ---------------------------------------------------------------------------

  @override
  String getTokenName() => _tokenName;

  // ---------------------------------------------------------------------------
  // CDOMToken<ConcretePrereqObject>
  // ---------------------------------------------------------------------------

  @override
  Type getTokenClass() {
    // TODO: return ConcretePrereqObject once ported.
    return dynamic;
  }

  @override
  ParseResult parseToken(LoadContext context, dynamic obj, String value) {
    // TODO: requires PrerequisiteParserInterface + context.getObjectContext().
    // Java logic:
    //   bool overrideQualify = false;
    //   String preValue = value;
    //   if (value.startsWith("Q:")) { preValue = value.substring(2); overrideQualify = true; }
    //   Prerequisite p = _prereqParser.parse(_tokenRoot, preValue, _invert, overrideQualify);
    //   if (p == null) return ParseResult.internalError;
    //   context.getObjectContext().put(obj, p);
    //   return ParseResult.success;
    throw UnimplementedError(
        'PreCompatibilityToken.parseToken: '
        'requires PrerequisiteParserInterface + ConcretePrereqObject context ops');
  }

  // ---------------------------------------------------------------------------
  // CDOMWriteToken<ConcretePrereqObject>  (from CDOMPrimaryToken)
  // ---------------------------------------------------------------------------

  @override
  List<String>? unparse(LoadContext context, dynamic obj) {
    // TODO: requires context.getObjectContext().getPrerequisiteChanges(obj)
    // and PrerequisiteWriterFactory to serialise Prerequisite objects.
    // Java logic iterates prerequisite changes, serialises matching ones via
    // PrerequisiteWriterInterface, filters by tokenName, and returns the values.
    throw UnimplementedError(
        'PreCompatibilityToken.unparse: '
        'requires PrerequisiteWriterFactory + prerequisite context changes');
  }

  // ---------------------------------------------------------------------------
  // CDOMSubToken<ConcretePrereqObject>  (from CDOMSecondaryToken)
  // ---------------------------------------------------------------------------

  @override
  String getParentToken() => '*KITTOKEN';

  // ---------------------------------------------------------------------------
  // Static compatibility level accessors (mirrors Java statics)
  // ---------------------------------------------------------------------------

  static int compatibilityLevel() => 5;
  static int compatibilityPriority() => 0;
  static int compatibilitySubLevel() => 14;
}
