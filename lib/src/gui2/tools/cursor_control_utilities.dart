// Translation of pcgen.gui2.tools.CursorControlUtilities

import 'package:flutter/material.dart';

/// Manages a global "wait / busy" overlay for the application.
///
/// In Swing the wait cursor was achieved by setting a glass-pane cursor and
/// making it visible so that it blocked mouse events.  In Flutter we replicate
/// this with a [ValueNotifier] that drives a full-screen [ModalBarrier] +
/// [CircularProgressIndicator] overlay rendered at the root of the widget tree.
///
/// Usage
/// -----
/// 1. Wrap your top-level widget with [CursorControlOverlay].
/// 2. Call [CursorControlUtilities.startWaiting] / [stopWaiting] from anywhere.
final class CursorControlUtilities {
  CursorControlUtilities._();

  static final ValueNotifier<bool> _waiting = ValueNotifier<bool>(false);

  /// A [ValueListenable] that is `true` while a wait state is active.
  static ValueListenable<bool> get waitingNotifier => _waiting;

  /// Show the wait cursor / block input.
  static void startWaiting() {
    _waiting.value = true;
  }

  /// Hide the wait cursor / restore input.
  static void stopWaiting() {
    _waiting.value = false;
  }

  /// Whether a wait state is currently active.
  static bool get isWaiting => _waiting.value;
}

/// A widget that wraps [child] and renders a blocking overlay whenever
/// [CursorControlUtilities.waitingNotifier] is true.
class CursorControlOverlay extends StatelessWidget {
  final Widget child;

  const CursorControlOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: CursorControlUtilities.waitingNotifier,
      builder: (context, isWaiting, _) {
        return Stack(
          children: [
            child,
            if (isWaiting) ...[
              const ModalBarrier(dismissible: false, color: Colors.transparent),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        );
      },
    );
  }
}
