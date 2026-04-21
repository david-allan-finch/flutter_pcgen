//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tools.PCGenAction

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common_menu_text.dart';
import 'icons.dart' as pcgen_icons;

/// Modifier key combinations used in accelerator strings.
enum _AcceleratorModifier {
  shortcut,
  alt,
  shiftShortcut,
  none,
}

/// Represents a single keyboard accelerator shortcut.
class PcGenAccelerator {
  final SingleActivator activator;

  const PcGenAccelerator(this.activator);
}

/// Base action class for PCGen menu items and toolbar buttons.
///
/// Equivalent to the Swing PCGenAction (an AbstractAction sub-class).
/// In Flutter, actions are modelled as data objects that carry display
/// properties; execution is handled by [onPressed].
class PcGenAction {
  /// Resolved display name.
  final String name;

  /// Optional tooltip / short description.
  final String? shortDescription;

  /// Optional mnemonic character.
  final String? mnemonic;

  /// Optional command identifier (ACTION_COMMAND_KEY equivalent).
  final String? command;

  /// Optional keyboard accelerator.
  final PcGenAccelerator? accelerator;

  /// Optional icon.
  final pcgen_icons.Icons? icon;

  /// Callback invoked when the action is triggered.  May be null to indicate
  /// a disabled / no-op action.
  final VoidCallback? onPressed;

  const PcGenAction({
    required this.name,
    this.shortDescription,
    this.mnemonic,
    this.command,
    this.accelerator,
    this.icon,
    this.onPressed,
  });

  // ---------------------------------------------------------------------------
  // Factory constructors mirroring the Java constructor overloads
  // ---------------------------------------------------------------------------

  factory PcGenAction.fromProp(
    String prop, {
    String? command,
    String? acceleratorString,
    pcgen_icons.Icons? icon,
    List<Object> substitutes = const [],
    VoidCallback? onPressed,
  }) {
    final props = CommonMenuText.resolve(prop, substitutes);
    final accelerator = acceleratorString != null
        ? _parseAccelerator(acceleratorString)
        : null;
    return PcGenAction(
      name: props.name,
      shortDescription: props.shortDescription,
      mnemonic: props.mnemonic,
      command: command,
      accelerator: accelerator,
      icon: icon,
      onPressed: onPressed,
    );
  }

  // ---------------------------------------------------------------------------
  // Widget helpers
  // ---------------------------------------------------------------------------

  /// Build a [MenuItemButton] from this action.
  MenuItemButton buildMenuItem(BuildContext context) {
    Widget? leadingIcon;
    if (icon != null) {
      leadingIcon = icon!.imageWidget(size: 16);
    }
    Widget label = Text(name);
    if (shortDescription != null && shortDescription!.isNotEmpty) {
      label = Tooltip(message: shortDescription!, child: label);
    }
    return MenuItemButton(
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      shortcut: accelerator?.activator,
      child: label,
    );
  }

  /// Build an [IconButton] from this action (for toolbar use).
  Widget buildToolbarButton(BuildContext context) {
    if (icon != null) {
      return Tooltip(
        message: shortDescription ?? name,
        child: IconButton(
          onPressed: onPressed,
          icon: icon!.imageWidget(size: 16),
        ),
      );
    }
    return Tooltip(
      message: shortDescription ?? name,
      child: TextButton(onPressed: onPressed, child: Text(name)),
    );
  }

  // ---------------------------------------------------------------------------
  // Accelerator parsing
  // ---------------------------------------------------------------------------

  static PcGenAccelerator? _parseAccelerator(String accelerator) {
    // Accelerator forms:
    //   "shortcut <key>"        → Ctrl/Cmd + key
    //   "shortcut-alt <key>"    → (unused in original but handled)
    //   "alt <key>"             → Alt + key
    //   "shift-shortcut <key>"  → Shift+Ctrl/Cmd + key
    //   "F<n>"                  → function key alone
    //   "<key>"                 → bare key

    final parts = accelerator.trim().split(RegExp(r'\s+'));

    _AcceleratorModifier modifier = _AcceleratorModifier.none;
    String keyName;

    if (parts.length == 2) {
      switch (parts[0].toLowerCase()) {
        case 'shortcut':
          modifier = _AcceleratorModifier.shortcut;
        case 'alt':
          modifier = _AcceleratorModifier.alt;
        case 'shift-shortcut':
          modifier = _AcceleratorModifier.shiftShortcut;
        default:
          modifier = _AcceleratorModifier.none;
      }
      keyName = parts[1];
    } else {
      keyName = parts[0];
    }

    final logicalKey = _logicalKeyFromName(keyName);
    if (logicalKey == null) return null;

    switch (modifier) {
      case _AcceleratorModifier.shortcut:
        return PcGenAccelerator(
          SingleActivator(logicalKey, control: true, meta: false),
        );
      case _AcceleratorModifier.alt:
        return PcGenAccelerator(
          SingleActivator(logicalKey, alt: true),
        );
      case _AcceleratorModifier.shiftShortcut:
        return PcGenAccelerator(
          SingleActivator(logicalKey, control: true, shift: true),
        );
      case _AcceleratorModifier.none:
        return PcGenAccelerator(SingleActivator(logicalKey));
    }
  }

  static LogicalKeyboardKey? _logicalKeyFromName(String name) {
    // Map common key names to LogicalKeyboardKey constants.
    const map = <String, LogicalKeyboardKey>{
      'A': LogicalKeyboardKey.keyA,
      'B': LogicalKeyboardKey.keyB,
      'C': LogicalKeyboardKey.keyC,
      'D': LogicalKeyboardKey.keyD,
      'E': LogicalKeyboardKey.keyE,
      'F': LogicalKeyboardKey.keyF,
      'G': LogicalKeyboardKey.keyG,
      'H': LogicalKeyboardKey.keyH,
      'I': LogicalKeyboardKey.keyI,
      'J': LogicalKeyboardKey.keyJ,
      'K': LogicalKeyboardKey.keyK,
      'L': LogicalKeyboardKey.keyL,
      'M': LogicalKeyboardKey.keyM,
      'N': LogicalKeyboardKey.keyN,
      'O': LogicalKeyboardKey.keyO,
      'P': LogicalKeyboardKey.keyP,
      'Q': LogicalKeyboardKey.keyQ,
      'R': LogicalKeyboardKey.keyR,
      'S': LogicalKeyboardKey.keyS,
      'T': LogicalKeyboardKey.keyT,
      'U': LogicalKeyboardKey.keyU,
      'V': LogicalKeyboardKey.keyV,
      'W': LogicalKeyboardKey.keyW,
      'X': LogicalKeyboardKey.keyX,
      'Y': LogicalKeyboardKey.keyY,
      'Z': LogicalKeyboardKey.keyZ,
      'F1': LogicalKeyboardKey.f1,
      'F2': LogicalKeyboardKey.f2,
      'F3': LogicalKeyboardKey.f3,
      'F4': LogicalKeyboardKey.f4,
      'F5': LogicalKeyboardKey.f5,
      'F6': LogicalKeyboardKey.f6,
      'F7': LogicalKeyboardKey.f7,
      'F8': LogicalKeyboardKey.f8,
      'F9': LogicalKeyboardKey.f9,
      'F10': LogicalKeyboardKey.f10,
      'F11': LogicalKeyboardKey.f11,
      'F12': LogicalKeyboardKey.f12,
      'DELETE': LogicalKeyboardKey.delete,
      'BACK_SPACE': LogicalKeyboardKey.backspace,
      'ENTER': LogicalKeyboardKey.enter,
      'ESCAPE': LogicalKeyboardKey.escape,
      'TAB': LogicalKeyboardKey.tab,
      'HOME': LogicalKeyboardKey.home,
      'END': LogicalKeyboardKey.end,
      'PAGE_UP': LogicalKeyboardKey.pageUp,
      'PAGE_DOWN': LogicalKeyboardKey.pageDown,
    };
    return map[name.toUpperCase()];
  }
}
