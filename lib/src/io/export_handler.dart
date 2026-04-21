//
// Copyright 2002 (C) Thomas Behr <ravenlock@gmx.de>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.io.ExportHandler

import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/io/export_exception.dart';
import 'package:flutter_pcgen/src/io/exporttoken/token.dart';

/// Abstract base class for character sheet export engines.
///
/// Concrete subclasses handle the two supported template formats:
///  - [PCGenExportHandler] for PCGen's own .ftl-adjacent token templates.
///  - FreeMarkerExportHandler (TBD) for FreeMarker .ftl templates.
///
/// Translation of pcgen.io.ExportHandler.
abstract class ExportHandler {
  final String templatePath;

  /// Static token registry, populated from registered export tokens.
  static final Map<String, Token> _tokenMap = {};
  static bool _tokenMapPopulated = false;

  // Processing state
  bool _existsOnly = false;
  bool _noMoreItems = false;
  int _currentListIndex = 0;

  ExportHandler(this.templatePath);

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Creates the appropriate [ExportHandler] for [templatePath].
  ///
  /// FreeMarker templates (.ftl) produce a FreeMarkerExportHandler; all
  /// other templates produce a [PCGenExportHandler].
  static ExportHandler createExportHandler(String templatePath) {
    if (templatePath.toLowerCase().endsWith('.ftl')) {
      // TODO: return FreeMarkerExportHandler(templatePath) when ported.
      throw ExportException(
          'FreeMarker export handler not yet implemented for: $templatePath');
    }
    return PCGenExportHandler(templatePath);
  }

  // ---------------------------------------------------------------------------
  // Core export API
  // ---------------------------------------------------------------------------

  /// Export [pc] to [output] using this handler's template.
  ///
  /// Subclasses must implement the full token-substitution logic.
  void export(PlayerCharacter pc, StringSink output);

  /// Export a party of [characters] to [output].
  void exportParty(List<PlayerCharacter> characters, StringSink output) {
    // Default: export each character sequentially using the same template.
    for (final pc in characters) {
      export(pc, output);
    }
  }

  // ---------------------------------------------------------------------------
  // Token registry
  // ---------------------------------------------------------------------------

  /// Registers [token] in the static export-token map.
  static void registerToken(Token token) {
    _tokenMap[token.getTokenName()] = token;
  }

  /// Returns the registered [Token] for [tokenName], or null.
  static Token? getToken(String tokenName) {
    _ensureTokenMapPopulated();
    return _tokenMap[tokenName];
  }

  static void _ensureTokenMapPopulated() {
    if (_tokenMapPopulated) return;
    // TODO: load tokens from plugin registry / manual registration.
    _tokenMapPopulated = true;
  }

  // ---------------------------------------------------------------------------
  // Template processing helpers
  // ---------------------------------------------------------------------------

  /// Returns the value of a single token [tokenName] for [pc].
  String? getTokenValue(String tokenName, PlayerCharacter pc) {
    final token = getToken(tokenName);
    if (token == null) return null;
    return token.getToken(tokenName, pc, this);
  }

  /// Returns whether the current FOR/IIF loop is in "exists only" mode.
  bool get existsOnly => _existsOnly;
  set existsOnly(bool v) => _existsOnly = v;

  bool get noMoreItems => _noMoreItems;
  set noMoreItems(bool v) => _noMoreItems = v;

  int get currentListIndex => _currentListIndex;
  set currentListIndex(int v) => _currentListIndex = v;
}

/// Default PCGen token-template export handler.
///
/// Reads the template file line by line and replaces |TOKEN| markers with
/// values from the character. Supports FOR/IIF control structures.
///
/// This is a concrete but partially-implemented class; the full template
/// engine will be completed when the exporttoken suite is fully ported.
class PCGenExportHandler extends ExportHandler {
  PCGenExportHandler(super.templatePath);

  @override
  void export(PlayerCharacter pc, StringSink output) {
    // TODO: implement full token template engine:
    //   1. Read templatePath as a text file.
    //   2. Split into lines; handle multi-line FOR/IIF blocks.
    //   3. For each line, tokenize on '|' and replace recognised tokens.
    //   4. Write processed output to [output].
    throw ExportException('PCGenExportHandler: full template engine not yet implemented');
  }
}
