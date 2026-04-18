// Copyright 2016 Andrew Maitland <amaitland@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.utils.DeferredLine

import '../source_entry.dart';

/// A line of LST text that was deferred during loading (e.g. because its
/// dependencies had not yet been loaded). Stores the source context and
/// the raw LST line for later processing.
class DeferredLine {
  final SourceEntry source;
  final String lstLine;

  const DeferredLine(this.source, this.lstLine);
}
