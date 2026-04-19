// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.CDOMKitLoader

import '../../rules/context/load_context.dart';
import 'c_d_o_m_sub_line_loader.dart';

/// Manages a set of [CDOMSubLineLoader]s keyed by their prefix strings and
/// dispatches Kit sub-lines to the appropriate one.
///
/// Translation of pcgen.rules.persistence.CDOMKitLoader.
class CDOMKitLoader {
  final Map<String, CDOMSubLineLoader<dynamic>> _loadMap = {};

  // ---------------------------------------------------------------------------
  // Loader registration
  // ---------------------------------------------------------------------------

  /// Registers [loader] under its prefix string.
  ///
  /// Each prefix may only be registered once.
  void addLineLoader(CDOMSubLineLoader<dynamic> loader) {
    final prefix = loader.getPrefix();
    if (_loadMap.containsKey(prefix)) {
      throw ArgumentError(
          'Cannot add a second CDOMSubLineLoader for prefix: $prefix');
    }
    _loadMap[prefix] = loader;
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  /// Parses a Kit sub-line, creating a new sub-object and adding it to [kit].
  ///
  /// The first tab-delimited field of [val] must be of the form PREFIX:Name.
  /// The prefix is used to locate the appropriate [CDOMSubLineLoader].
  bool parseSubLine(LoadContext context, dynamic kit, String val, Uri source) {
    final sepLoc = val.indexOf('\t');
    final firstToken = sepLoc == -1 ? val : val.substring(0, sepLoc);

    final colonLoc = firstToken.indexOf(':');
    if (colonLoc == -1) {
      print('LST_ERROR: Line without a colon in first token: $val in $source');
      return false;
    }

    final prefix = firstToken.substring(0, colonLoc);
    final loader = _loadMap[prefix];
    if (loader == null) {
      print('LST_ERROR: Unknown prefix "$prefix" in line: $val in $source');
      return false;
    }

    return _subParse(context, kit, loader, val);
  }

  bool _subParse<T>(
      LoadContext context, dynamic kit, CDOMSubLineLoader<T> loader, String line) {
    final obj = loader.getCDOMObject();
    // TODO: add obj to kit's KIT_TASKS list via context.getObjectContext()
    //       once ListKey.KIT_TASKS and the object context are fully ported.
    return loader.parseLine(context, obj, line);
  }

  // ---------------------------------------------------------------------------
  // Kit object lookup / construction
  // ---------------------------------------------------------------------------

  /// Returns an existing Kit named [name] from the reference context, or
  /// constructs and registers a new one.
  dynamic getCDOMObject(LoadContext context, String name) {
    // TODO: use context.getReferenceContext() to look up / create Kit once
    //       the Kit type is fully ported.
    return null;
  }
}
