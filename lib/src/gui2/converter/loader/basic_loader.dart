// Translation of pcgen.gui2.converter.loader.BasicLoader

import '../conversion_decider.dart';
import '../loader.dart';
import '../token_converter.dart';
import '../event/token_process_event.dart';

/// Generic loader that processes LST files for a single CDOMObject type [T].
/// Each tab-separated field after the object name is processed as a token.
class BasicLoader<T> implements Loader {
  static const String fieldSeparator = '\t';

  /// The dynamic class identifier used to construct CDOMObjects.
  final Type cdomClass;

  /// The list-key under which files are stored on a Campaign.
  final dynamic listKey;

  /// The load context.
  final dynamic context;

  /// Sink for logging converted tokens.
  final StringSink changeLogWriter;

  BasicLoader({
    required this.context,
    required this.cdomClass,
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
    final tokens = lineString.split(fieldSeparator);
    if (tokens.isEmpty) return null;

    final objectName = tokens[0];
    sb.write(objectName);
    final list = <dynamic>[];

    for (int tok = 1; tok < tokens.length; tok++) {
      final token = tokens[tok];
      sb.write(fieldSeparator);
      if (token.isEmpty) continue;

      final obj = context
          .getReferenceContext()
          .constructCDOMObject(cdomClass, '${line}Test$tok $token');
      obj.put('CONVERT_NAME', tokens[0]);

      final injected = _processToken(sb, objectName, obj, token, decider, line);
      if (injected != null) list.addAll(injected);

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
