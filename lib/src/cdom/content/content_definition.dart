//
// Copyright 2014-15 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.content.ContentDefinition
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'user_content.dart';

// Visibility levels for ContentDefinition fields.
enum Visibility {
  hidden,
  display,
  export,
  yes,
  qualify;

  bool isVisibleTo(View view) {
    switch (this) {
      case Visibility.yes:
      case Visibility.display:
        return view == View.visibleDisplay || view == View.visibleExport;
      case Visibility.export:
        return view == View.visibleExport;
      default:
        return false;
    }
  }
}

enum View {
  visibleDisplay,
  visibleExport,
}

// Abstract base for dynamic content definitions (FACT, FACTSET, GLOBALVAR, etc.).
// Manages usable location, format manager, visibility, and selection settings.
abstract class ContentDefinition<T extends CDOMObject, F>
    extends UserContent {
  String? _displayName;
  Type? _usableLocation;
  FormatManager<F>? _formatManager;
  Visibility? _visibility;
  bool? _selectable;
  bool? _required;

  @override
  String getDisplayName() => _displayName ?? getKeyName();

  void setDisplayName(String name) => _displayName = name;

  void setUsableLocation(Type cl) => _usableLocation = cl;

  Type? getUsableLocation() => _usableLocation;

  FormatManager<F>? setFormatManager(FormatManager<F> fmtManager) {
    final old = _formatManager;
    _formatManager = fmtManager;
    return old;
  }

  FormatManager<F>? getFormatManager() => _formatManager;

  void setVisibility(Visibility vis) => _visibility = vis;

  Visibility? getVisibility() => _visibility;

  void setSelectable(bool set) => _selectable = set;

  bool? getSelectable() => _selectable;

  void setRequired(bool set) {
    if (set && _usableLocation == CDOMObject) {
      throw UnsupportedError('Global ContentDefinition cannot be required');
    }
    _required = set;
  }

  bool? getRequired() => _required;

  void activate(dynamic context) {
    activateKey();
    final vis = _visibility ?? Visibility.hidden;
    if (vis.isVisibleTo(View.visibleExport)) {
      activateOutput(context.getDataSetID());
    }
    activateTokens(context);
  }

  void activateKey();
  void activateOutput(dynamic dsID);
  void activateTokens(dynamic context);
}
