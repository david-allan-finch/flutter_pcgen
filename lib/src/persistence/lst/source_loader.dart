// Copyright 2016 Andrew Maitland <amaitland@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.SourceLoader

/// Parses SOURCE token lines from LST files, committing each token to the
/// load context via addStatefulToken.
class SourceLoader {
  SourceLoader._();

  static void parseLine(dynamic context, String lstLine, Uri sourceFile) {
    final tokens = lstLine.split('\t');
    for (final col in tokens) {
      final colString = col.trim();
      if (colString.isEmpty) continue;
      final ok = context.addStatefulToken(colString);
      if (ok) {
        context.commit();
      } else {
        context.rollback();
      }
    }
  }
}
