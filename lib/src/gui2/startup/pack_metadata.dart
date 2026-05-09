// Metadata models for PCGen's two archive formats:
//   .pcglst — game data pack (system/ + data/ + pack.json)
//   .pcgch  — character archive (*.pcg files + characters.json)

class PackMetadata {
  final String id;
  final String name;
  final String version;
  final String? gameMode;
  final String? description;
  final String? author;
  final String? minAppVersion;
  final List<String> contents;

  const PackMetadata({
    required this.id,
    required this.name,
    required this.version,
    this.gameMode,
    this.description,
    this.author,
    this.minAppVersion,
    this.contents = const [],
  });

  factory PackMetadata.fromJson(Map<String, dynamic> j) => PackMetadata(
        id: j['id'] as String? ?? 'unknown',
        name: j['name'] as String? ?? 'Unknown Pack',
        version: j['version'] as String? ?? '0.0.0',
        gameMode: j['gameMode'] as String?,
        description: j['description'] as String?,
        author: j['author'] as String?,
        minAppVersion: j['minAppVersion'] as String?,
        contents: (j['contents'] as List?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        if (gameMode != null) 'gameMode': gameMode,
        if (description != null) 'description': description,
        if (author != null) 'author': author,
        if (minAppVersion != null) 'minAppVersion': minAppVersion,
        'contents': contents,
      };
}

// ─── Installed pack tracking ──────────────────────────────────────────────────

class InstalledPack {
  final PackMetadata metadata;
  final DateTime installedAt;

  const InstalledPack({required this.metadata, required this.installedAt});

  factory InstalledPack.fromJson(Map<String, dynamic> j) => InstalledPack(
        metadata: PackMetadata.fromJson(j['metadata'] as Map<String, dynamic>),
        installedAt: DateTime.tryParse(j['installedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'installedAt': installedAt.toIso8601String(),
      };
}

// ─── Catalogue entry (available for download) ─────────────────────────────────

class CatalogueEntry {
  final PackMetadata metadata;
  final String url;
  final String sizeMb;

  const CatalogueEntry({
    required this.metadata,
    required this.url,
    required this.sizeMb,
  });
}

// ─── Character archive metadata (.pcgch) ──────────────────────────────────────

class CharacterArchiveMetadata {
  final String version;
  final String appVersion;
  final String exportDate;
  final List<CharacterSummary> characters;

  const CharacterArchiveMetadata({
    required this.version,
    required this.appVersion,
    required this.exportDate,
    required this.characters,
  });

  int get characterCount => characters.length;

  factory CharacterArchiveMetadata.fromJson(Map<String, dynamic> j) =>
      CharacterArchiveMetadata(
        version: j['version'] as String? ?? '1.0.0',
        appVersion: j['appVersion'] as String? ?? '',
        exportDate: j['exportDate'] as String? ?? '',
        characters: (j['characters'] as List? ?? [])
            .map((e) => CharacterSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'appVersion': appVersion,
        'exportDate': exportDate,
        'characterCount': characterCount,
        'characters': characters.map((c) => c.toJson()).toList(),
      };
}

class CharacterSummary {
  final String file;
  final String name;
  final String race;
  final String classes;
  final int level;

  const CharacterSummary({
    required this.file,
    required this.name,
    required this.race,
    required this.classes,
    required this.level,
  });

  factory CharacterSummary.fromJson(Map<String, dynamic> j) => CharacterSummary(
        file: j['file'] as String? ?? '',
        name: j['name'] as String? ?? '',
        race: j['race'] as String? ?? '',
        classes: j['classes'] as String? ?? '',
        level: (j['level'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'file': file,
        'name': name,
        'race': race,
        'classes': classes,
        'level': level,
      };
}
