//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.preloader.PCGenPreloader

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui3/preloader/pc_gen_preloader_controller.dart';

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
