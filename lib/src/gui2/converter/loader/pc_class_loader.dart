//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.converter.loader.PCClassLoader

import 'package:flutter_pcgen/src/gui2/converter/conversion_decider.dart';
import 'package:flutter_pcgen/src/gui2/converter/loader.dart';
import 'package:flutter_pcgen/src/gui2/converter/token_converter.dart';
import 'package:flutter_pcgen/src/gui2/converter/event/token_process_event.dart';

/// Loader dedicated to converting PCClass and class-level LST data.
/// Determines the correct CDOMObject subtype from the first token on each
/// line (CLASS:, SUBCLASS:, etc.) and processes remaining tokens accordingly.
class PCClassLoader implements Loader {
  static const String _fieldSeparator = '\t';

  final dynamic context;
  final StringSink changeLogWriter;

  PCClassLoader({required this.context, required this.changeLogWriter});

  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    final list = <dynamic>[];
    final tokens = lineString.split(_fieldSeparator);
    if (tokens.isEmpty) return list;

    final firstToken = tokens[0];
    sb.write(firstToken);

    String buildClass;
    String? buildParent;

    if (firstToken.startsWith('SUBCLASS:')) {
      buildClass = 'SubClass';
    } else if (firstToken.startsWith('SUBCLASSLEVEL:')) {
      buildClass = 'PCClassLevel';
      buildParent = 'SubClass';
    } else if (firstToken.startsWith('SUBSTITUTIONCLASS:')) {
      buildClass = 'SubstitutionClass';
    } else if (firstToken.startsWith('SUBSTITUTIONLEVEL:')) {
      buildClass = 'PCClassLevel';
      buildParent = 'SubstitutionClass';
    } else if (firstToken.startsWith('CLASS:')) {
      buildClass = 'PCClass';
    } else {
      buildClass = 'PCClassLevel';
      buildParent = 'PCClass';
    }

    for (int tok = 1; tok < tokens.length; tok++) {
      final token = tokens[tok];
      sb.write(_fieldSeparator);
      if (token.isEmpty) continue;

      final obj = context
          .getReferenceContext()
          .constructCDOMObject(buildClass, '${line}Test$tok');

      dynamic parent;
      if (buildClass == 'PCClassLevel') {
        obj.put('LEVEL', 1);
        if (buildParent != null) {
          parent = context
              .getReferenceContext()
              .constructCDOMObject(buildParent, '${line}Test$tok');
          try {
            obj.put('TOKEN_PARENT', parent.clone());
          } catch (_) {
            print('ERROR: Unable to prepare a copy of $parent');
          }
        }
      }

      final injected =
          _processToken(sb, firstToken, obj, parent, token, decider, line);
      if (injected != null) list.addAll(injected);

      context.purge(obj);
      if (parent != null) context.purge(parent);
      TokenConverter.clear();
    }
    return list;
  }

  List<dynamic>? _processToken(
    StringBuffer sb,
    String firstToken,
    dynamic obj,
    dynamic alt,
    String token,
    ConversionDecider decider,
    int line,
  ) {
    final colonLoc = token.indexOf(':');
    if (colonLoc == -1) {
      print('ERROR: Invalid Token - does not contain a colon: $token');
      return null;
    }
    if (colonLoc == 0) {
      print('ERROR: Invalid Token - starts with a colon: $token');
      return null;
    }

    final key = token.substring(0, colonLoc);
    final value =
        (colonLoc == token.length - 1) ? null : token.substring(colonLoc + 1);

    var tpe = TokenProcessEvent(
      context: context,
      decider: decider,
      key: key,
      value: value,
      objectName: firstToken,
      primary: obj,
    );
    final error = StringBuffer(TokenConverter.process(tpe) ?? '');

    if (!tpe.isConsumed() && alt != null) {
      tpe = TokenProcessEvent(
        context: context,
        decider: decider,
        key: key,
        value: value,
        objectName: firstToken,
        primary: alt,
      );
      error.write(TokenConverter.process(tpe) ?? '');
    }

    if (tpe.isConsumed()) {
      if (token != tpe.getResult()) {
        changeLogWriter.writeln(
          "Line $line converted '$token' to '${tpe.getResult()}'.",
        );
      }
      sb.write(tpe.getResult());
    } else {
      print('ERROR: $error');
    }
    return tpe.getInjected();
  }

  @override
  List<dynamic> getFiles(dynamic campaign) {
    return campaign.getSafeListFor('FILE_CLASS') as List<dynamic>;
  }
}
