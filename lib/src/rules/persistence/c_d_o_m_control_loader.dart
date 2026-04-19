// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.CDOMControlLoader

import '../../cdom/base/loadable.dart' show Loadable;
import '../../persistence/lst/lst_line_file_loader.dart';
import '../../rules/context/load_context.dart';
import 'c_d_o_m_sub_line_loader.dart';

/// Loads DATACONTROL LST files (FACT, FACTSET, DEFAULTVARIABLEVALUE, etc.).
///
/// Each line is dispatched to a registered [CDOMSubLineLoader] based on the
/// prefix that appears before the first colon of the line's first token.
///
/// Translation of pcgen.rules.persistence.CDOMControlLoader.
class CDOMControlLoader extends LstLineFileLoader {
  final Map<String, CDOMSubLineLoader<dynamic>> _loadMap = {};

  CDOMControlLoader() {
    // Register the standard DATACONTROL prefixes.
    // TODO: replace placeholder factories with real constructors once
    //       FactDefinition, FactSetDefinition, DefaultVarValue, UserFunction,
    //       and DynamicCategory types are ported.
    _addLineLoader(_makePlaceholderLoader('FACTDEF'));
    _addLineLoader(_makePlaceholderLoader('FACTSETDEF'));
    _addLineLoader(_makePlaceholderLoader('DEFAULTVARIABLEVALUE'));
    _addLineLoader(_makePlaceholderLoader('FUNCTION'));
    _addLineLoader(_makePlaceholderLoader('DYNAMICSCOPE'));
  }

  /// Convenience: create a placeholder loader that produces a [_RawLoadable].
  static CDOMSubLineLoader<_RawLoadable> _makePlaceholderLoader(String prefix) {
    return CDOMSubLineLoader<_RawLoadable>(prefix, () => _RawLoadable(prefix));
  }

  // ---------------------------------------------------------------------------
  // Loader registration
  // ---------------------------------------------------------------------------

  void _addLineLoader(CDOMSubLineLoader<dynamic> loader) {
    final prefix = loader.getPrefix();
    if (_loadMap.containsKey(prefix)) {
      throw ArgumentError(
          'Cannot add a second loader for prefix: $prefix');
    }
    _loadMap[loader.getPrefix()] = loader;
  }

  // ---------------------------------------------------------------------------
  // LstLineFileLoader implementation
  // ---------------------------------------------------------------------------

  @override
  void parseLine(LoadContext context, String inputLine, Uri uri) {
    context.rollback();
    if (_parseSubLine(context, inputLine, uri)) {
      context.commit();
    } else {
      context.rollback();
    }
  }

  bool _parseSubLine(LoadContext context, String val, Uri source) {
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

    return _subParse(context, loader, val);
  }

  bool _subParse<T>(
      LoadContext context, CDOMSubLineLoader<T> loader, String line) {
    final tabLoc = line.indexOf('\t');
    final lineIdentifier = tabLoc == -1 ? line : line.substring(0, tabLoc);

    final colonLoc = lineIdentifier.indexOf(':');
    if (colonLoc == -1) {
      print('ERROR: First token on line had no colon: $line');
      return false;
    }

    final rawName = lineIdentifier.substring(colonLoc + 1);
    if (rawName.isEmpty) {
      print('ERROR: First token on line had no content: $line');
      return false;
    }

    // Normalise name: pipe and comma become space (matches Java behaviour).
    final name = rawName.replaceAll('|', ' ').replaceAll(',', ' ');

    // TODO: use context.getReferenceContext().constructNowIfNecessary(
    //       loader.getLoadedClass(), name) once the reference context is ported.
    final obj = loader.getCDOMObject();
    return loader.parseLine(context, obj, line);
  }
}

// ---------------------------------------------------------------------------
// Placeholder Loadable used until concrete DATACONTROL types are ported
// ---------------------------------------------------------------------------

class _RawLoadable implements Loadable {
  final String prefix;
  String _name = '';
  String? _sourceUri;

  _RawLoadable(this.prefix);

  @override
  String getDisplayName() => _name;

  @override
  String getKeyName() => _name;

  @override
  void setName(String name) => _name = name;

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String? uri) => _sourceUri = uri;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
