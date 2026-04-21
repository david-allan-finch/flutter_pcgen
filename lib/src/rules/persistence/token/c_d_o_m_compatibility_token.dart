// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMCompatibilityToken

import 'package:flutter_pcgen/src/rules/persistence/token/cdom_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/compatibility_token.dart';

/// A [CDOMCompatibilityToken] implements a tag syntax from a previous version
/// of PCGen.
///
/// Once a [CDOMToken] becomes deprecated it is reclassified as a
/// [CDOMCompatibilityToken] so the loader can still handle old data files
/// while new tokens take over the canonical form.
///
/// This is a unifying interface – it simply extends both [CDOMToken] and
/// [CompatibilityToken].
///
/// [T] is the type of object on which this token operates.
///
/// Mirrors Java: CDOMCompatibilityToken<T> extends CDOMToken<T>, CompatibilityToken
abstract interface class CDOMCompatibilityToken<T>
    implements CDOMToken<T>, CompatibilityToken {}
