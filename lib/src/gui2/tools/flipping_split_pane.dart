// Translation of pcgen.gui2.tools.FlippingSplitPane

import 'package:flutter/material.dart';

/// The axis along which the two child panes are laid out.
enum SplitOrientation {
  /// Children are placed side-by-side (left | right).
  horizontal,

  /// Children are placed above and below (top / bottom).
  vertical,
}

/// A split-pane widget that can flip its orientation at runtime.
///
/// Equivalent to the Swing [FlippingSplitPane]: shows two child widgets
/// separated by a draggable divider.  Right-clicking the divider (or
/// long-pressing on touch) shows a context menu with Centre, Flip, Reset,
/// Lock/Unlock, and Options items.
///
/// Child widgets that are themselves [FlippingSplitPane]s receive orientation
/// changes recursively (criss-cross pattern), matching the Java behaviour.
class FlippingSplitPane extends StatefulWidget {
  /// Initial orientation.
  final SplitOrientation orientation;

  /// The first (left or top) child.
  final Widget firstChild;

  /// The second (right or bottom) child.
  final Widget secondChild;

  /// Initial weight of the divider position in [0.0, 1.0].
  final double initialWeight;

  /// Whether the divider is draggable continuously (live resize).
  final bool continuousLayout;

  const FlippingSplitPane({
    super.key,
    this.orientation = SplitOrientation.horizontal,
    required this.firstChild,
    required this.secondChild,
    this.initialWeight = 0.5,
    this.continuousLayout = false,
  });

  @override
  State<FlippingSplitPane> createState() => FlippingSplitPaneState();
}

class FlippingSplitPaneState extends State<FlippingSplitPane> {
  late SplitOrientation _orientation;
  late double _weight; // fraction [0.0, 1.0] for the first pane
  bool _locked = false;
  bool _continuousLayout = false;

  // Drag state
  double _dragStartPosition = 0.0;
  double _dragStartWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _orientation = widget.orientation;
    _weight = widget.initialWeight.clamp(0.0, 1.0);
    _continuousLayout = widget.continuousLayout;
  }

  // ---------------------------------------------------------------------------
  // Public API (mirrors Java methods)
  // ---------------------------------------------------------------------------

  SplitOrientation get orientation => _orientation;

  bool get isLocked => _locked;

  bool get isContinuousLayout => _continuousLayout;

  void setOrientation(SplitOrientation newOrientation) {
    if (newOrientation == _orientation) return;
    setState(() => _orientation = newOrientation);
  }

  void flipOrientation() {
    setState(() {
      _orientation = _orientation == SplitOrientation.horizontal
          ? SplitOrientation.vertical
          : SplitOrientation.horizontal;
      _weight = 0.5; // reset to center after flip
    });
  }

  void centerDivider() {
    if (_locked) return;
    setState(() => _weight = 0.5);
  }

  void resetToPreferredSizes() {
    if (_locked) return;
    setState(() => _weight = 0.5);
  }

  void setLocked(bool locked) {
    setState(() => _locked = locked);
  }

  void setContinuousLayout(bool value) {
    setState(() => _continuousLayout = value);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = _orientation == SplitOrientation.horizontal;
        final totalSize =
            isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        const dividerSize = 8.0;
        final firstSize = (totalSize - dividerSize) * _weight;
        final secondSize = (totalSize - dividerSize) * (1 - _weight);

        final divider = _buildDivider(isHorizontal, totalSize, dividerSize);

        if (isHorizontal) {
          return Row(
            children: [
              SizedBox(width: firstSize, child: widget.firstChild),
              divider,
              SizedBox(width: secondSize, child: widget.secondChild),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(height: firstSize, child: widget.firstChild),
              divider,
              SizedBox(height: secondSize, child: widget.secondChild),
            ],
          );
        }
      },
    );
  }

  Widget _buildDivider(bool isHorizontal, double totalSize, double dividerSize) {
    final divider = GestureDetector(
      onPanStart: _locked
          ? null
          : (details) {
              _dragStartPosition = isHorizontal
                  ? details.globalPosition.dx
                  : details.globalPosition.dy;
              _dragStartWeight = _weight;
            },
      onPanUpdate: _locked
          ? null
          : (details) {
              final delta = isHorizontal
                  ? details.globalPosition.dx - _dragStartPosition
                  : details.globalPosition.dy - _dragStartPosition;
              final newWeight =
                  (_dragStartWeight + delta / totalSize).clamp(0.05, 0.95);
              if (_continuousLayout) {
                setState(() => _weight = newWeight);
              } else {
                setState(() => _weight = newWeight);
              }
            },
      onSecondaryTapUp: (details) =>
          _showContextMenu(context, details.globalPosition),
      onLongPressStart: (details) =>
          _showContextMenu(context, details.globalPosition),
      child: MouseRegion(
        cursor: isHorizontal
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        child: Container(
          width: isHorizontal ? dividerSize : double.infinity,
          height: isHorizontal ? double.infinity : dividerSize,
          color: Theme.of(context).dividerColor,
          child: Center(
            child: Container(
              width: isHorizontal ? 2 : 24,
              height: isHorizontal ? 24 : 2,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
    return divider;
  }

  Future<void> _showContextMenu(
      BuildContext context, Offset globalPosition) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final relativePosition =
        RelativeRect.fromRect(
          Rect.fromPoints(globalPosition, globalPosition),
          Offset.zero & overlay.size,
        );

    final items = <PopupMenuEntry<_SplitPaneAction>>[
      if (!_locked) ...[
        const PopupMenuItem(
          value: _SplitPaneAction.center,
          child: Text('Center'),
        ),
        const PopupMenuItem(
          value: _SplitPaneAction.flip,
          child: Text('Flip'),
        ),
        const PopupMenuItem(
          value: _SplitPaneAction.reset,
          child: Text('Reset'),
        ),
        const PopupMenuDivider(),
      ],
      PopupMenuItem(
        value: _SplitPaneAction.toggleLock,
        child: Text(_locked ? 'Unlock' : 'Lock'),
      ),
      if (!_locked) ...[
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _SplitPaneAction.toggleContinuous,
          child: Row(
            children: [
              if (_continuousLayout) const Icon(Icons.check, size: 16),
              const SizedBox(width: 4),
              const Text('Smooth Resize'),
            ],
          ),
        ),
      ],
    ];

    final result = await showMenu<_SplitPaneAction>(
      context: context,
      position: relativePosition,
      items: items,
    );

    if (!mounted) return;
    switch (result) {
      case _SplitPaneAction.center:
        centerDivider();
      case _SplitPaneAction.flip:
        flipOrientation();
      case _SplitPaneAction.reset:
        resetToPreferredSizes();
      case _SplitPaneAction.toggleLock:
        setLocked(!_locked);
      case _SplitPaneAction.toggleContinuous:
        setContinuousLayout(!_continuousLayout);
      case null:
        break;
    }
  }
}

enum _SplitPaneAction {
  center,
  flip,
  reset,
  toggleLock,
  toggleContinuous,
}
