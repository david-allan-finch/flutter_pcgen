//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.converter.ObjectInjector

import 'dart:io';

import 'package:flutter_pcgen/src/gui2/converter/lst_converter.dart';
import 'package:flutter_pcgen/src/gui2/converter/loader.dart';

/// Collects CDOMObjects that were injected during conversion and writes them
/// into new LST files in the output directory, also updating the relevant PCC
/// campaign files with references to those new files.
class ObjectInjector {
  /// uri → className → fileName → lines
  final Map<Uri, Map<String, Map<String, List<String>>>> _campaignData = {};

  /// uri → outputFile → lines
  final Map<Uri, Map<File, List<String>>> _fileData = {};

  final Iterable<Loader> _loaders;
  final Directory outDir;
  final Directory rootDir;

  ObjectInjector({
    required dynamic context,
    required this.outDir,
    required this.rootDir,
    required LSTConverter converter,
  }) : _loaders = converter.getInjectedLoaders() {
    for (final loader in _loaders) {
      for (final uri in converter.getInjectedUris(loader)) {
        for (final obj in converter.getInjectedObjects(loader, uri)) {
          final cl = obj.runtimeType.toString();
          String className = cl.contains('EquipmentModifier') ? 'EQUIPMOD' : cl.toUpperCase();
          final fileName = '${className.toLowerCase()}_516_conversion.lst';
          context.setExtractUri(uri);
          final List<String>? result =
              (context.unparse(obj) as Iterable?)?.cast<String>().toList();
          if (result != null) {
            final line = '${obj.getDisplayName()}\t${result.join('\t')}';
            final outFile = _getOutputFile(uri, fileName);
            _fileData
                .putIfAbsent(uri, () => {})
                .putIfAbsent(outFile, () => [])
                .add(line);
            _campaignData
                .putIfAbsent(uri, () => {})
                .putIfAbsent(className, () => {})
                .putIfAbsent(fileName, () => [])
                .add(line);
          }
        }
      }
    }
  }

  File _getOutputFile(Uri uri, String fileName) {
    final outFile =
        File('${_getNewOutputName(uri).parent.path}${Platform.pathSeparator}$fileName');
    if (outFile.existsSync()) {
      stderr.writeln('Won\'t overwrite: $outFile');
    }
    return outFile;
  }

  File _getNewOutputName(Uri uri) {
    final inFile = File.fromUri(uri);
    final base = _findSubRoot(rootDir, inFile);
    final relative = inFile.path.substring(base!.path.length + 1);
    final commonRoot = _generateCommonRoot(rootDir, outDir);
    final outString = outDir.path.substring(commonRoot.path.length);
    return File(
        '${commonRoot.path}${Platform.pathSeparator}$outString${Platform.pathSeparator}$relative');
  }

  /// Writes all injected objects to their respective files and updates
  /// the campaign PCC files with references to those new files.
  Future<void> writeInjectedObjects(List<dynamic> campaignList) async {
    final affectedUris = <Uri>[];
    bool first = true;

    for (final campaign in campaignList) {
      for (final loader in _loaders) {
        for (final cse in loader.getFiles(campaign)) {
          final uri = cse.getUri() as Uri;
          first = await _processWrite(campaign, cse, first);
          affectedUris.add(uri);
        }
      }
    }

    for (final uri in affectedUris) {
      final files = _fileData[uri];
      if (files != null) {
        for (final entry in files.entries) {
          _writeFile(entry.key, entry.value);
        }
      }
    }
  }

  void _writeFile(File f, List<String> lines) {
    final sink = f.openWrite();
    sink.write(_getFileHeader());
    for (final line in lines) {
      sink.writeln(line);
    }
    sink.write(_getFileFooter());
    sink.close();
  }

  String _getFileHeader() {
    return '# This file was automatically created during dataset conversion'
        ' by PCGen on ${DateTime.now().toUtc()}\n'
        '# This file does not contain SOURCE information\n';
  }

  String _getFileFooter() => '\n#\n#EOF\n#\n';

  Future<bool> _processWrite(
    dynamic campaign,
    dynamic cse,
    bool needHeader,
  ) async {
    final uri = cse.getUri() as Uri;
    final classNames = _campaignData[uri];
    if (classNames != null) {
      final campaignFile = _getNewOutputName(campaign.getSourceUri() as Uri);
      final sink = campaignFile.openWrite(mode: FileMode.append);
      if (needHeader) sink.write(_getCampaignInsertInfo());
      for (final classEntry in classNames.entries) {
        final className = classEntry.key;
        for (final fileName in classEntry.value.keys) {
          final writeCse = cse.getRelatedTarget(fileName);
          sink.write('$className:${writeCse.getLstFormat()}\n');
        }
      }
      await sink.close();
      return false;
    }
    return true;
  }

  String _getCampaignInsertInfo() {
    return '\n#\n# The following file(s) were automatically added'
        ' during dataset conversion by PCGen'
        ' on ${DateTime.now().toUtc()}\n#\n';
  }

  Directory? _findSubRoot(Directory root, File inFile) {
    Directory? current = inFile.parent;
    while (true) {
      if (current.path == root.path) return current;
      final parent = current.parent;
      if (parent.path == current.path) return null;
      current = parent;
    }
  }

  Directory _generateCommonRoot(Directory a, Directory b) {
    if (a.path == b.path) return a;
    final aList = _generateDirectoryHierarchy(a);
    final bList = _generateDirectoryHierarchy(b);
    Directory? result;
    for (int i = 0; i < aList.length && i < bList.length; i++) {
      if (aList[i].path == bList[i].path) {
        result = aList[i];
      } else {
        break;
      }
    }
    return result ?? a;
  }

  List<Directory> _generateDirectoryHierarchy(Directory a) {
    final list = <Directory>[];
    Directory current = a;
    while (true) {
      list.insert(0, current);
      final parent = current.parent;
      if (parent.path == current.path) break;
      current = parent;
    }
    return list;
  }
}
