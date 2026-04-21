// Translation of pcgen.gui3.preloader.PCGenPreloader

import 'package:flutter/material.dart';
import 'pc_gen_preloader_controller.dart';

/// Splash/preloader screen shown while PCGen initializes.
class PCGenPreloader extends StatefulWidget {
  final PCGenPreloaderController controller;
  final VoidCallback? onComplete;

  const PCGenPreloader({
    super.key,
    required this.controller,
    this.onComplete,
  });

  @override
  State<PCGenPreloader> createState() => _PCGenPreloaderState();
}

class _PCGenPreloaderState extends State<PCGenPreloader> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    if (widget.controller.isComplete) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PCGen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'RPG Character Generator',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 300,
              child: LinearProgressIndicator(
                value: widget.controller.progress > 0
                    ? widget.controller.progress
                    : null,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.controller.statusMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
