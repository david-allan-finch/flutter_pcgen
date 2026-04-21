// Copyright 2004 Frugal <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.output.prereq.PrerequisiteWriterFactory

import 'package:flutter_pcgen/src/persistence/lst/output/prereq/prerequisite_writer_interface.dart';

/// Singleton factory that maps Prerequisite kind strings to their LST writers.
class PrerequisiteWriterFactory {
  static PrerequisiteWriterFactory? _instance;

  final Map<String, PrerequisiteWriterInterface> _parserLookup = {};

  PrerequisiteWriterFactory._();

  static PrerequisiteWriterFactory getInstance() =>
      _instance ??= PrerequisiteWriterFactory._();

  PrerequisiteWriterInterface? getWriter(String? kind) {
    if (kind == null) {
      // Equivalent to Java's new PreMultWriter()
      // TODO: return PreMultWriter() once translated
      return null;
    }
    return _parserLookup[kind.toLowerCase()];
  }

  void register(PrerequisiteWriterInterface writer) {
    _parserLookup[writer.kindHandled().toLowerCase()] = writer;
  }

  static void clear() {
    _instance?._parserLookup.clear();
  }
}
