// Translation of pcgen.gui2.converter.LSTConverter

import 'dart:io';

import 'conversion_decider.dart';
import 'loader.dart';
import 'loader/ability_loader.dart';
import 'loader/basic_loader.dart';
import 'loader/copy_loader.dart';
import 'loader/equipment_loader.dart';
import 'loader/pc_class_loader.dart';
import 'loader/self_copy_loader.dart';

/// Observable orchestrator that drives the conversion of LST campaign files.
/// Each registered [Loader] is asked to enumerate its files for a given
/// [Campaign] and each file is read, converted line-by-line, and written to
/// the output directory.
class LSTConverter {
  final dynamic context;
  final Directory rootDir;
  final String outDir;
  final ConversionDecider decider;
  final StringSink changeLogWriter;
  late final List<Loader> _loaders;
  final Set<Uri> _written = {};

  /// Map: loader → uri → list of injected CDOMObjects
  final Map<Loader, Map<Uri, List<dynamic>>> _injected = {};

  /// Observers notified with the current file URI as each file is processed.
  final List<void Function(Uri)> _observers = [];

  LSTConverter({
    required this.context,
    required this.rootDir,
    required this.outDir,
    required this.decider,
    required this.changeLogWriter,
  }) {
    _loaders = _setupLoaders(context, changeLogWriter);
  }

  void addObserver(void Function(Uri) observer) => _observers.add(observer);
  void removeObserver(void Function(Uri) observer) =>
      _observers.remove(observer);

  void _notifyObservers(Uri uri) {
    for (final obs in _observers) {
      obs(uri);
    }
  }

  /// Returns the number of LST files referenced by [campaign] across all loaders.
  int getNumFilesInCampaign(dynamic campaign) {
    int count = 0;
    for (final loader in _loaders) {
      count += loader.getFiles(campaign).length;
    }
    return count;
  }

  /// Loads ability-category and similar bootstrap data for [campaigns] before
  /// conversion begins.
  void initCampaigns(List<dynamic> campaigns) {
    for (final campaign in campaigns) {
      try {
        context
            .getCatLoader()
            .loadLstFiles(context, campaign.getSafeListFor('FILE_ABILITY_CATEGORY'));
        context
            .getSizeLoader()
            .loadLstFiles(context, campaign.getSafeListFor('FILE_SIZE'));
        context
            .getStatLoader()
            .loadLstFiles(context, campaign.getSafeListFor('FILE_STAT'));
        context
            .getSavesLoader()
            .loadLstFiles(context, campaign.getSafeListFor('FILE_SAVE'));
        context
            .getAlignmentLoader()
            .loadLstFiles(context, campaign.getSafeListFor('FILE_ALIGNMENT'));
      } catch (e) {
        print('ERROR: LSTConverter.initCampaigns: $e');
      }
    }
  }

  /// Converts all LST files referenced by [campaign].
  void processCampaign(dynamic campaign) => _startItem(campaign);

  void _startItem(dynamic campaign) {
    for (final loader in _loaders) {
      final files = loader.getFiles(campaign);
      for (final cse in files) {
        final uri = cse.getUri() as Uri;
        _notifyObservers(uri);

        if (uri.scheme.toLowerCase() != 'file') {
          print(
            'WARNING: Skipping $uri from ${campaign.getSourceUri()} - not a local file.',
          );
          continue;
        }

        final inFile = File.fromUri(uri);
        Uri canonicalUri;
        try {
          canonicalUri = inFile.resolveSymbolicLinksSync().uri;
        } catch (e) {
          print('WARNING: Skipping $uri - could not make canonical: $e');
          continue;
        }

        if (_written.contains(canonicalUri)) continue;
        _written.add(canonicalUri);

        final base = _findSubRoot(rootDir, inFile);
        if (base == null) {
          print(
            'WARNING: Skipping $uri - not in selected source directory.',
          );
          continue;
        }

        final relative =
            inFile.path.substring(base.path.length + 1);
        if (!inFile.existsSync()) {
          print('WARNING: Skipping $uri - file does not exist.');
          continue;
        }

        final outFile = File('$outDir${Platform.pathSeparator}$relative');
        if (outFile.existsSync()) {
          print('WARNING: Won\'t overwrite: $outFile');
          continue;
        }

        _ensureParents(outFile.parent);

        try {
          changeLogWriter.writeln('\nProcessing $inFile');
          final result = _load(uri, loader);
          if (result != null) {
            outFile.writeAsStringSync(result);
          }
        } catch (e) {
          print('ERROR: $e');
        }
      }
    }
  }

  List<Loader> _setupLoaders(dynamic context, StringSink changeLogWriter) {
    return [
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_WEAPON_PROF',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_ARMOR_PROF',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_SHIELD_PROF',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_SKILL',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_LANGUAGE',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_FEAT',
        changeLogWriter: changeLogWriter,
      ),
      AbilityLoader(
        context: context,
        listKey: 'FILE_ABILITY',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_RACE',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_DOMAIN',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_SPELL',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_DEITY',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_TEMPLATE',
        changeLogWriter: changeLogWriter,
      ),
      EquipmentLoader(
        context: context,
        listKey: 'FILE_EQUIP',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_EQUIP_MOD',
        changeLogWriter: changeLogWriter,
      ),
      BasicLoader(
        context: context,
        cdomClass: dynamic,
        listKey: 'FILE_COMPANION_MOD',
        changeLogWriter: changeLogWriter,
      ),
      PCClassLoader(context: context, changeLogWriter: changeLogWriter),
      CopyLoader('FILE_ABILITY_CATEGORY'),
      CopyLoader('LICENSE_FILE'),
      CopyLoader('FILE_KIT'),
      CopyLoader('FILE_BIO_SET'),
      CopyLoader('FILE_DATACTRL'),
      CopyLoader('FILE_STAT'),
      CopyLoader('FILE_SAVE'),
      CopyLoader('FILE_SIZE'),
      CopyLoader('FILE_ALIGNMENT'),
      CopyLoader('FILE_PCC'),
      SelfCopyLoader(),
    ];
  }

  void _ensureParents(Directory dir) {
    if (!dir.existsSync()) {
      _ensureParents(dir.parent);
      dir.createSync();
    }
  }

  Directory? _findSubRoot(Directory root, File inFile) {
    Directory? parent = inFile.parent;
    while (parent != null) {
      if (parent.path == root.path) return parent;
      final grandParent = parent.parent;
      if (grandParent.path == parent.path) return null; // filesystem root
      parent = grandParent;
    }
    return null;
  }

  String? _load(Uri uri, Loader loader) {
    context.setSourceUri(uri);
    context.setExtractUri(uri);

    final file = File.fromUri(uri);
    if (!file.existsSync()) return null;

    final dataBuffer = file.readAsStringSync();
    final resultBuffer = StringBuffer();

    final fileLines = dataBuffer.split(RegExp(r'\r?\n|\r'));
    for (int line = 0; line < fileLines.length; line++) {
      final lineString = fileLines[line];
      if (lineString.isEmpty ||
          lineString.startsWith('#') ||
          lineString.startsWith('SOURCE')) {
        resultBuffer.write(lineString);
      } else {
        try {
          final newObj =
              loader.process(resultBuffer, line, lineString, decider);
          if (newObj != null) {
            for (final cdo in newObj) {
              _injected
                  .putIfAbsent(loader, () => {})
                  .putIfAbsent(uri, () => [])
                  .add(cdo);
            }
          }
        } catch (e) {
          print('ERROR loading $uri line $line: $e');
          return null;
        }
      }
      resultBuffer.writeln();
    }
    return resultBuffer.toString();
  }

  /// Returns all loaders that have injected objects.
  Iterable<Loader> getInjectedLoaders() => _injected.keys;

  /// Returns all URIs for which [loader] has injected objects.
  Iterable<Uri> getInjectedUris(Loader loader) =>
      _injected[loader]?.keys ?? const [];

  /// Returns all injected objects for [loader] at [uri].
  List<dynamic> getInjectedObjects(Loader loader, Uri uri) =>
      _injected[loader]?[uri] ?? const [];
}
