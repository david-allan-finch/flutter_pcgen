// Translation of pcgen.gui2.tools.Utility

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Miscellaneous convenience utilities.
///
/// Equivalent to the Swing Utility class.
final class Utility {
  Utility._();

  // ---------------------------------------------------------------------------
  // Escape-to-close for dialogs
  // ---------------------------------------------------------------------------

  /// Returns a [CallbackShortcuts] wrapper around [child] that closes the
  /// nearest [Navigator] route (i.e. the enclosing dialog) when the user
  /// presses Escape.
  ///
  /// Usage:
  /// ```dart
  /// showDialog(
  ///   context: context,
  ///   builder: (ctx) => Utility.escapeClosable(ctx, child: MyDialog()),
  /// );
  /// ```
  static Widget escapeClosable(BuildContext context, {required Widget child}) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }

  // ---------------------------------------------------------------------------
  // Image / rectangle helpers
  // ---------------------------------------------------------------------------

  /// Adjust [cropRect] to fit within [imageWidth] x [imageHeight] and make it
  /// square.
  ///
  /// Equivalent to Java's `adjustRectToFitImage`.
  static Rect adjustRectToFitImage(
    int imageWidth,
    int imageHeight,
    Rect cropRect,
  ) {
    double w = cropRect.width > imageWidth ? imageWidth.toDouble() : cropRect.width;
    double h = cropRect.height > imageHeight ? imageHeight.toDouble() : cropRect.height;

    // Make square
    final dimension = w < h ? w : h;
    w = dimension;
    h = dimension;

    // Clamp origin so the box stays within the image
    double x = cropRect.left;
    double y = cropRect.top;
    if (x + w > imageWidth) x = imageWidth - w;
    if (y + h > imageHeight) y = imageHeight - h;
    if (x < 0) x = 0;
    if (y < 0) y = 0;

    return Rect.fromLTWH(x, y, w, h);
  }

  // ---------------------------------------------------------------------------
  // String helpers
  // ---------------------------------------------------------------------------

  /// Shorten [str] from the left so that it renders within [maxWidth] logical
  /// pixels using [textStyle].
  ///
  /// Equivalent to Java's `shortenString(FontMetrics, String, int)`.
  static String shortenString(String str, double maxWidth, TextStyle textStyle) {
    if (str.isEmpty) return '';

    final painter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      text: TextSpan(text: str, style: textStyle),
    )..layout();

    if (painter.width <= maxWidth) return str;

    for (int i = str.length; i > 0; i -= 5) {
      final candidate = '...${str.substring(str.length - i)}';
      final p = TextPainter(
        textDirection: ui.TextDirection.ltr,
        text: TextSpan(text: candidate, style: textStyle),
      )..layout();
      if (p.width < maxWidth) return candidate;
    }
    return '';
  }

  // ---------------------------------------------------------------------------
  // Mouse / pointer helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when [event] represents a Shift + primary-button press.
  ///
  /// Equivalent to Java's `isShiftLeftMouseButton(InputEvent)`.
  static bool isShiftLeftMouseButton(PointerEvent event) {
    return event.buttons == kPrimaryMouseButton &&
        HardwareKeyboard.instance.isShiftPressed;
  }

  // ---------------------------------------------------------------------------
  // Tab pane helpers
  // ---------------------------------------------------------------------------

  /// Walk up the widget tree from [context] and return the nearest
  /// [DefaultTabController]'s index, or -1 if none is found.
  ///
  /// Equivalent to Java's `getTabbedPaneFor(Component)`.
  static int getTabIndexFor(BuildContext context) {
    final controller = DefaultTabController.maybeOf(context);
    return controller?.index ?? -1;
  }

  // ---------------------------------------------------------------------------
  // GridBag-style constraint helpers (Dart records variant)
  // ---------------------------------------------------------------------------

  /// A simple data class carrying the subset of GridBagConstraints that PCGen
  /// uses.  Flutter layouts do not use GridBag, but callers that do manual
  /// positioning may find this useful.
  static GridConstraints buildConstraints({
    required int gridX,
    required int gridY,
    required int gridWidth,
    required int gridHeight,
    required double weightX,
    required double weightY,
    int fill = 0,
    int anchor = 0,
  }) {
    return GridConstraints(
      gridX: gridX,
      gridY: gridY,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      weightX: weightX,
      weightY: weightY,
      fill: fill,
      anchor: anchor,
    );
  }

  /// Build relative (auto-positioned) constraints.
  static GridConstraints buildRelativeConstraints({
    required int gridWidth,
    required int gridHeight,
    required double weightX,
    required double weightY,
    int fill = 0,
    int anchor = 0,
  }) {
    return GridConstraints(
      gridX: -1, // RELATIVE
      gridY: -1, // RELATIVE
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      weightX: weightX,
      weightY: weightY,
      fill: fill,
      anchor: anchor,
    );
  }
}

/// Dart equivalent of a subset of [java.awt.GridBagConstraints].
class GridConstraints {
  /// Column index (-1 = RELATIVE).
  final int gridX;

  /// Row index (-1 = RELATIVE).
  final int gridY;

  /// Number of columns spanned.
  final int gridWidth;

  /// Number of rows spanned.
  final int gridHeight;

  /// Horizontal weight.
  final double weightX;

  /// Vertical weight.
  final double weightY;

  /// Fill mode (0 = NONE, 1 = HORIZONTAL, 2 = VERTICAL, 3 = BOTH).
  final int fill;

  /// Anchor constant.
  final int anchor;

  const GridConstraints({
    required this.gridX,
    required this.gridY,
    required this.gridWidth,
    required this.gridHeight,
    required this.weightX,
    required this.weightY,
    this.fill = 0,
    this.anchor = 0,
  });
}
