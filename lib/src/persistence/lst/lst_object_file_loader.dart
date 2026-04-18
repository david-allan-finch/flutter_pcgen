import '../../cdom/base/cdom_object.dart';
import '../../rules/context/load_context.dart';
import '../persistence_layer_exception.dart';
import 'campaign_source_entry.dart';
import 'lst_file_loader.dart';
import 'source_entry.dart';

// Abstract base loader for CDOMObjects from LST files.
// Handles .MOD / .COPY / .FORGET processing around a parseLine hook.
abstract class LstObjectFileLoader<T extends CDOMObject> {
  static const String fieldSeparator = '\t';
  static const String copySuffix = '.COPY';
  static const String modSuffix = '.MOD';
  static const String forgetSuffix = '.FORGET';

  final List<_ModEntry<T>> _copyLineList = [];
  final List<String> _forgetLineList = [];
  final List<List<_ModEntry<T>>> _modEntryList = [];
  bool _processComplete = true;
  final List<String> _excludedObjects = [];

  /// Parse a single LST line into [target], returning the (possibly new) object.
  T? parseLine(LoadContext context, T? target, String lstLine, SourceEntry source);

  /// Look up an existing object by key.
  T? getObjectKeyed(LoadContext context, String key);

  /// Load a list of LST files and apply MOD/COPY/FORGET directives.
  Future<void> loadLstFiles(LoadContext context, List<CampaignSourceEntry> fileList) async {
    _processComplete = true;
    final loaded = <CampaignSourceEntry>{};
    for (final sourceEntry in fileList) {
      if (!loaded.contains(sourceEntry)) {
        await _loadLstFile(context, sourceEntry);
        loaded.add(sourceEntry);
      }
    }
    _processCopies(context);
    _processComplete = false;
    _processMods(context);
    _processForgets(context);
  }

  Future<void> _loadLstFile(LoadContext context, CampaignSourceEntry sourceEntry) async {
    final uri = sourceEntry.getURI();
    final content = await LstFileLoader.readFromURI(uri);
    if (content == null) return;

    context.setSourceURI(uri);
    T? target;
    List<_ModEntry<T>>? classModLines;

    final lines = content.split(RegExp(LstFileLoader.lineSeparatorRegexp));
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty || line.codeUnitAt(0) == LstFileLoader.lineCommentChar) continue;

      final sepLoc = line.indexOf(fieldSeparator);
      final firstToken = sepLoc == -1 ? line : line.substring(0, sepLoc);

      if (classModLines != null) {
        if (firstToken.startsWith('CLASS:')) {
          _modEntryList.add(classModLines);
          classModLines = null;
        } else {
          classModLines.add(_ModEntry(sourceEntry, line, i + 1));
          continue;
        }
      }

      if (line.startsWith('SOURCE')) {
        // SOURCE lines are processed by SourceLoader — skip here
      } else if (firstToken.contains(copySuffix)) {
        _copyLineList.add(_ModEntry(sourceEntry, line, i + 1));
      } else if (firstToken.contains(modSuffix)) {
        if (firstToken.startsWith('CLASS:')) {
          classModLines = [_ModEntry(sourceEntry, line, i + 1)];
        } else {
          _modEntryList.add([_ModEntry(sourceEntry, line, i + 1)]);
        }
      } else if (firstToken.contains(forgetSuffix)) {
        _forgetLineList.add(line);
      } else {
        try {
          target = parseLine(context, target, line, sourceEntry);
        } catch (e) {
          stderr.writeln('ERROR parsing $uri line ${i+1}: $e');
        }
      }
    }
    if (classModLines != null) _modEntryList.add(classModLines);
    if (target != null) completeObject(context, sourceEntry, target);
  }

  void completeObject(LoadContext context, SourceEntry source, T obj) {
    if (!_processComplete || obj == null) return;
    if (includeObject(source, obj)) {
      _storeObject(context, obj);
    } else {
      _excludedObjects.add(obj.getKeyName());
    }
  }

  bool includeObject(SourceEntry source, CDOMObject cdo) {
    final display = cdo.getDisplayName();
    final key = cdo.getKeyName();
    if (display == null || display.trim().isEmpty || key.trim().isEmpty) return false;
    final inc = source.getIncludeItems();
    if (inc.isNotEmpty) return inc.contains(key);
    final exc = source.getExcludeItems();
    if (exc.isNotEmpty) return !exc.contains(key);
    return true;
  }

  void _storeObject(LoadContext context, T obj) {
    final current = getMatchingObject(context, obj);
    if (current != null && current != obj) {
      context.getReferenceContext().register(obj);
    } else if (current == null) {
      context.getReferenceContext().register(obj);
    }
  }

  T? getMatchingObject(LoadContext context, CDOMObject key) =>
      getObjectKeyed(context, key.getKeyName());

  void _processCopies(LoadContext context) {
    for (final me in _copyLineList) {
      _performCopy(context, me);
    }
    _copyLineList.clear();
  }

  void _performCopy(LoadContext context, _ModEntry<T> me) {
    final lstLine = me.lstLine;
    final sepLoc = lstLine.indexOf(fieldSeparator);
    final name = sepLoc == -1 ? lstLine : lstLine.substring(0, sepLoc);
    final nameEnd = name.indexOf(copySuffix);
    final baseName = name.substring(0, nameEnd);
    final copyName = name.substring(nameEnd + copySuffix.length);
    final obj = getObjectKeyed(context, baseName);
    if (obj == null) return;
    // In full impl: context.performCopy(obj, copyName)
  }

  void _processMods(LoadContext context) {
    for (final entryList in _modEntryList) {
      _performMod(context, entryList);
    }
    _modEntryList.clear();
  }

  void _performMod(LoadContext context, List<_ModEntry<T>> entryList) {
    if (entryList.isEmpty) return;
    final entry = entryList[0];
    int nameEnd = entry.lstLine.indexOf(modSuffix);
    String key = entry.lstLine.substring(0, nameEnd);
    final nameStart = key.indexOf(':');
    if (nameStart > 0) key = key.substring(nameStart + 1);

    T? object = getObjectKeyed(context, key);
    if (object == null) return;

    for (final modEntry in entryList) {
      context.setSourceURI(modEntry.source.getURI());
      try {
        parseLine(context, object, modEntry.lstLine, modEntry.source);
      } catch (e) {
        stderr.writeln('ERROR in .MOD of $key: $e');
      }
    }
    completeObject(context, entry.source, object!);
  }

  void _processForgets(LoadContext context) {
    for (String key in _forgetLineList) {
      key = key.substring(0, key.indexOf(forgetSuffix));
      if (_excludedObjects.contains(key)) continue;
      // In full impl: context.getReferenceContext().forget(obj)
    }
    _forgetLineList.clear();
  }
}

class _ModEntry<T> {
  final SourceEntry source;
  final String lstLine;
  final int lineNumber;
  _ModEntry(this.source, this.lstLine, this.lineNumber);
}

// ignore: avoid_print
final stderr = _Stderr();
class _Stderr {
  void writeln(Object? msg) { print(msg); }
}
