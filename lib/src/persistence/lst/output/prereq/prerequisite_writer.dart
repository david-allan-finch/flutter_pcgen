// Copyright 2004 Frugal <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.output.prereq.PrerequisiteWriter

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'prerequisite_writer_factory.dart';

/// Serialises Prerequisite objects back to their LST string representation.
class PrerequisiteWriter {
  void write(StringSink writer, Prerequisite prereq) {
    final factory = PrerequisiteWriterFactory.getInstance();
    final w = factory.getWriter(prereq.kind);
    if (w == null) {
      throw StateError(
          'Can not find a Writer for prerequisites of kind: ${prereq.kind}');
    }
    w.write(writer, prereq);
  }

  /// Converts a list of prerequisites to a pipe-separated LST string.
  String getPrerequisiteString(List<Prerequisite> prereqs) =>
      _getPrereqString(prereqs, '|');

  static String prereqsToString(dynamic pObj) {
    if (pObj.hasPrerequisites()) {
      final writer = PrerequisiteWriter();
      return writer._getPrereqString(
          List<Prerequisite>.from(pObj.getPrerequisiteList()), '\t');
    }
    return '';
  }

  String _getPrereqString(List<Prerequisite> prereqs, String separator) {
    if (prereqs.isEmpty) return '';
    final results = <String>{};
    for (final prereq in prereqs) {
      final sb = StringBuffer();
      write(sb, prereq);
      results.add(sb.toString());
    }
    final sorted = results.toList()..sort();
    return sorted.join(separator);
  }
}
