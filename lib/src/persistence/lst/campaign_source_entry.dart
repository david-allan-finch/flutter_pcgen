//
// Copyright 2003 (C) David Hibbs <sage_sam@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.persistence.lst.CampaignSourceEntry
import 'package:flutter_pcgen/src/cdom/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';

// Associates a Campaign with an LST source file URI, with optional include/exclude/prereq filters.
class CampaignSourceEntry implements SourceEntry {
  final Campaign _campaign;
  final String _uri;
  List<String> _includeItems = [];
  List<String> _excludeItems = [];
  final List<Prerequisite> _prerequisites = [];

  CampaignSourceEntry(this._campaign, this._uri);

  @override
  Campaign getCampaign() => _campaign;

  @override
  String getURI() => _uri;

  @override
  List<String> getIncludeItems() => _includeItems;

  @override
  List<String> getExcludeItems() => _excludeItems;

  @override
  List<Prerequisite> getPrerequisites() => _prerequisites;

  String getLSTformat([bool useAny = false]) {
    final sb = StringBuffer(_uri);
    if (_includeItems.isNotEmpty) {
      sb.write('|(INCLUDE:${_includeItems.join('|')})');
    } else if (_excludeItems.isNotEmpty) {
      sb.write('|(EXCLUDE:${_excludeItems.join('|')})');
    }
    return sb.toString();
  }

  /// Parse a CSE from a pipe-delimited value like "path/file.lst|(INCLUDE:Item1|Item2)".
  static CampaignSourceEntry? getNewCSE(Campaign campaign, String sourceUri, String value) {
    if (value.isEmpty) return null;

    final pipePos = value.indexOf('|');
    final CampaignSourceEntry cse;

    if (pipePos == -1) {
      final resolvedUri = _resolveUri(sourceUri, value);
      cse = CampaignSourceEntry(campaign, resolvedUri);
    } else {
      final fileUri = _resolveUri(sourceUri, value.substring(0, pipePos));
      cse = CampaignSourceEntry(campaign, fileUri);
      final suffix = value.substring(pipePos + 1);
      final tags = _parseSuffix(suffix);
      if (tags == null) return null;
      for (final tag in tags) {
        if (tag.startsWith('(INCLUDE:')) {
          final items = tag.substring(9, tag.length - 1).split('|');
          cse._includeItems = items;
        } else if (tag.startsWith('(EXCLUDE:')) {
          final items = tag.substring(9, tag.length - 1).split('|');
          cse._excludeItems = items;
        }
      }
    }
    return cse;
  }

  static String _resolveUri(String baseUri, String relative) {
    try {
      // '@' is PCGen's data-root token — expand it to the configured data dir.
      final expanded = relative.startsWith('@')
          ? Uri.file(ConfigurationSettings.getPccFilesDir())
                .toString()
                .replaceAll(RegExp(r'/$'), '') +
              relative.substring(1)
          : relative;
      final base = Uri.parse(baseUri);
      return base.resolve(expanded).toString();
    } catch (_) {
      return relative;
    }
  }

  static List<String>? _parseSuffix(String suffix) {
    final tags = <String>[];
    final current = StringBuffer();
    int bracketLevel = 0;
    for (int i = 0; i < suffix.length; i++) {
      final c = suffix[i];
      if (c == '(') {
        bracketLevel++;
        current.write(c);
      } else if (c == ')') {
        if (bracketLevel > 0) bracketLevel--;
        current.write(c);
      } else if (c == '|' && bracketLevel == 0) {
        if (current.isNotEmpty) {
          tags.add(current.toString());
          current.clear();
        }
      } else {
        current.write(c);
      }
    }
    if (current.isNotEmpty) tags.add(current.toString());
    if (bracketLevel > 0) return null; // mismatched parens
    return tags;
  }

  CampaignSourceEntry getRelatedTarget(String fileName) {
    return CampaignSourceEntry(_campaign, _resolveUri(_uri, fileName));
  }

  @override
  bool operator ==(Object other) =>
      other is CampaignSourceEntry &&
      _uri == other._uri &&
      _includeItems == other._includeItems &&
      _excludeItems == other._excludeItems;

  @override
  int get hashCode => _uri.hashCode;

  @override
  String toString() => 'Campaign: ${_campaign.getDisplayName()}; SourceFile: $_uri';
}
