// Copyright (c) PCGen contributors.
//
// Translation of pcgen.core.utils.SortedProperties

import 'dart:io';

/// A properties map whose file output is written in sorted key order.
class SortedProperties {
  final Map<String, String> _map = {};

  void setProperty(String key, String value) => _map[key] = value;
  String? getProperty(String key) => _map[key];

  Iterable<String> get keys => _map.keys;

  /// Writes properties to [out] in sorted key order, with a [header] comment.
  Future<void> store(File file, String header) async {
    final sorted = Map.fromEntries(
        _map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    final sink = file.openWrite(encoding: latin1);
    sink.writeln(header);

    for (final entry in sorted.entries) {
      final key = _convertStringToKey(entry.key);
      final value = _fixUp(entry.value);
      sink.writeln('$key=$value');
    }
    await sink.flush();
    await sink.close();
  }

  static String _convertStringToKey(String s) =>
      s.replaceAll(' ', '\\ ').replaceAll(':', '\\:').replaceAll('=', '\\=');

  static String _fixUp(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}
