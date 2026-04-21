// Copyright 2010 Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.SimplePrefixLoader

import 'package:flutter_pcgen/src/persistence/lst/simple_loader.dart';

/// A SimpleLoader that requires the first token to start with a specific
/// prefix key (e.g. "ABILITYCATEGORY:Name").
class SimplePrefixLoader<T> extends SimpleLoader<T> {
  final String _prefixString;

  SimplePrefixLoader(super.loadClass, String prefix)
      : _prefixString = prefix.isNotEmpty
            ? prefix
            : throw ArgumentError('Prefix cannot be empty');

  @override
  String? processFirstToken(dynamic context, String token) {
    final colonLoc = token.indexOf(':');
    if (colonLoc == -1 || colonLoc == 0 || colonLoc == token.length - 1) {
      // TODO: log error
      return null;
    }
    final key = token.substring(0, colonLoc);
    if (key != _prefixString) {
      // TODO: log error
      return null;
    }
    var value = token.substring(colonLoc + 1);
    // In-locale string lookup (i18n keys start with "in_")
    // TODO: resolve LanguageBundle.getString(value) if value.startsWith('in_')
    return super.processFirstToken(context, value);
  }
}
