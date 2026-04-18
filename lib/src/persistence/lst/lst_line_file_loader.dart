import '../../rules/context/load_context.dart';
import '../persistence_layer_exception.dart';
import 'campaign_source_entry.dart';
import 'lst_file_loader.dart';

// Base loader for non-CDOMObject LST data (system files: sizes, paper, etc.)
// Unlike LstObjectFileLoader, does not handle .MOD/.COPY/.FORGET.
abstract class LstLineFileLoader {
  final Set<String> _loadedFiles = {};

  /// Load a list of files, invoking [parseLine] for each content line.
  Future<void> loadLstFiles(LoadContext context, List<CampaignSourceEntry> fileList) async {
    for (final sourceEntry in fileList) {
      final uri = sourceEntry.getURI();
      if (_loadedFiles.contains(uri)) continue;
      _loadedFiles.add(uri);
      await _loadLstFile(context, sourceEntry);
    }
  }

  Future<void> _loadLstFile(LoadContext context, CampaignSourceEntry sourceEntry) async {
    final uri = sourceEntry.getURI();
    final content = await LstFileLoader.readFromURI(uri);
    if (content == null) return;

    context.setSourceURI(uri);
    final lines = content.split(RegExp(LstFileLoader.lineSeparatorRegexp));
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty || line.codeUnitAt(0) == LstFileLoader.lineCommentChar) continue;
      try {
        parseLine(context, line, Uri.parse(uri));
      } catch (e) {
        print('ERROR parsing $uri line ${i+1}: $e');
      }
    }
  }

  /// Parse a single content line. Subclasses implement this.
  void parseLine(LoadContext context, String lstLine, Uri uri);
}
