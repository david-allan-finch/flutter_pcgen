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
// Translation of pcgen.gui2.converter.loader.EquipmentLoader

import '../conversion_decider.dart';
import '../loader.dart';
import '../token_converter.dart';
import '../event/token_process_event.dart';

/// Loader for Equipment LST files. Mirrors [BasicLoader] but also purges
/// the equipment head objects that may be created as side-effects during
/// token processing.
class EquipmentLoader implements Loader {
  static const String _fieldSeparator = '\t';

  final dynamic listKey;
  final dynamic context;
  final StringSink changeLogWriter;

  EquipmentLoader({
    required this.context,
    required this.listKey,
    required this.changeLogWriter,
  });

  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    final tokens = lineString.split(_fieldSeparator);
    if (tokens.isEmpty) return null;

    final objectName = tokens[0];
    sb.write(objectName);
    final list = <dynamic>[];

    for (int tok = 1; tok < tokens.length; tok++) {
      final token = tokens[tok];
      sb.write(_fieldSeparator);
      if (token.isEmpty) continue;

      final obj = context
          .getReferenceContext()
          .constructCDOMObject('Equipment', '${line}Test$tok $token');
      obj.put('CONVERT_NAME', tokens[0]);

      final injected = _processToken(sb, objectName, obj, token, decider, line);
      if (injected != null) list.addAll(injected);

      // Purge equipment heads created as side-effects.
      final h1 = obj.getEquipmentHeadReference(1);
      if (h1 != null) context.purge(h1);
      final h2 = obj.getEquipmentHeadReference(2);
      if (h2 != null) context.purge(h2);
      context.purge(obj);
      TokenConverter.clear();
    }
    return list;
  }

  List<dynamic>? _processToken(
    StringBuffer sb,
    String objectName,
    dynamic obj,
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

    final tpe = TokenProcessEvent(
      context: context,
      decider: decider,
      key: key,
      value: value,
      objectName: objectName,
      primary: obj,
    );
    final error = TokenConverter.process(tpe);
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
    return campaign.getSafeListFor(listKey) as List<dynamic>;
  }
}
