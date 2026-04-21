// Copyright 2010 Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.SimpleLoader

import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_utils.dart';

/// A loader that parses simple tab-delimited LST lines into Loadable objects.
///
/// The first tab-column is the object name/key; subsequent columns are tokens
/// passed to [LstUtils.processToken].
class SimpleLoader<T> extends LstLineFileLoader {
  final Type _loadClass;

  SimpleLoader(this._loadClass);

  Type getLoadClass() => _loadClass;

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    final tokens = lstLine.split('\t');
    if (tokens.isEmpty) return;
    final firstToken = tokens[0].trim();
    final loadable = getLoadable(context, firstToken, sourceUri);
    if (loadable == null) return;
    for (int i = 1; i < tokens.length; i++) {
      processNonFirstToken(context, sourceUri, tokens[i], loadable);
    }
  }

  void processNonFirstToken(
      dynamic context, Uri sourceUri, String token, dynamic loadable) {
    LstUtils.processToken(context, loadable, sourceUri, token);
  }

  T? getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    final name = processFirstToken(context, firstToken);
    if (name == null) return null;
    final loadable =
        context.getReferenceContext().constructCDOMObject(_loadClass, name);
    loadable?.setSourceUri(sourceUri);
    return loadable as T?;
  }

  String? processFirstToken(dynamic context, String token) => token;
}
