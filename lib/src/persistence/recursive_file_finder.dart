import 'dart:io';

// Recursively searches a directory for .pcc files.
class RecursiveFileFinder {
  void findFiles(Directory aDirectory, List<String> campaignFiles) {
    if (!aDirectory.existsSync()) return;
    _findFiles(aDirectory, campaignFiles);
  }

  void _findFiles(Directory aDirectory, List<String> campaignFiles) {
    for (final entity in aDirectory.listSync()) {
      if (entity is Directory) {
        _findFiles(entity, campaignFiles);
      } else if (entity is File &&
          entity.path.toLowerCase().endsWith('.pcc')) {
        campaignFiles.add(entity.uri.toString());
      }
    }
  }
}
