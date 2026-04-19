// Translation of pcgen.persistence.lst.GenericLocalVariableLoader

import '../../rules/context/load_context.dart';
import 'lst_line_file_loader.dart';
import 'source_entry.dart';

/// Loads local variable definitions from LST files for a specific scope.
///
/// In Java this is parameterized by the scope class. Each line defines a
/// variable name and optional type for that scope.
class GenericLocalVariableLoader extends LstLineFileLoader {
  final String scopeName;

  GenericLocalVariableLoader(this.scopeName);

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final cols = lstLine.split('\t');
    if (cols.isEmpty) return;

    final firstToken = cols[0].trim();
    if (firstToken.isEmpty) return;

    // In the full implementation:
    // 1. Parse the variable name from firstToken
    // 2. Create a DatasetVariable for the given scope
    // 3. Apply remaining tokens (DEFINE, type, etc.)
    // TODO: full variable registration via rules context
  }
}
