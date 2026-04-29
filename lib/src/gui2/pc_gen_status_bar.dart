//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.PCGenStatusBar

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Status bar displayed at the bottom of the PCGen frame.
/// Shows source loading progress and error/warning icons.
class PCGenStatusBar extends StatefulWidget {
  final dynamic frame; // PCGenFrame

  const PCGenStatusBar({super.key, required this.frame});

  @override
  State<PCGenStatusBar> createState() => PCGenStatusBarState();
}

class PCGenStatusBarState extends State<PCGenStatusBar> {
  String? _contextMessage;
  bool _progressVisible = false;
  bool _indeterminate = false;
  double _progress = 0.0;
  String? _progressString;
  _LoadStatus _loadStatus = _LoadStatus.none;
  int _errorCount = 0;
  int _warningCount = 0;

  void setContextMessage(String? message) {
    setState(() => _contextMessage = message);
  }

  String? getContextMessage() => _contextMessage;

  void startShowingProgress(String msg, bool indeterminate) {
    setState(() {
      _contextMessage = msg;
      _progressVisible = true;
      _indeterminate = indeterminate;
      _progressString = msg;
      _progress = 0.0;
    });
  }

  void updateProgress(double value, String? label) {
    setState(() {
      _progress = value.clamp(0.0, 1.0);
      if (label != null) _progressString = label;
    });
  }

  void endShowingProgress() {
    setState(() {
      _contextMessage = null;
      _progressString = null;
      _progressVisible = false;
      _progress = 0.0;
    });
  }

  void setSourceLoadErrors(List<dynamic> errors) {
    int nerrors = 0, nwarnings = 0;
    for (final record in errors) {
      final level = record.level as int? ?? 0;
      if (level > 900) {
        nerrors++;
      } else if (level > 800) {
        nwarnings++;
      }
    }
    setState(() {
      _errorCount = nerrors;
      _warningCount = nwarnings;
      if (nerrors > 0) {
        _loadStatus = _LoadStatus.error;
      } else if (nwarnings > 0) {
        _loadStatus = _LoadStatus.warning;
      } else {
        _loadStatus = _LoadStatus.ok;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        return ValueListenableBuilder(
          valueListenable: loadedDataSet,
          builder: (context, dataset, _) {
            String charGameMode = '';
            try {
              charGameMode =
                  (character as dynamic).getGameMode() as String? ?? '';
            } catch (_) {}
            final loadedMode = dataset?.gameModeStr ?? '';
            final hasMismatch = charGameMode.isNotEmpty &&
                loadedMode.isNotEmpty &&
                charGameMode.toLowerCase() != loadedMode.toLowerCase();
            final sourcesLoaded = dataset != null;

            return Container(
              height: 26,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  // Progress / context message
                  if (_contextMessage != null)
                    Text(_contextMessage!,
                        style: const TextStyle(fontSize: 12)),

                  if (_progressVisible) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 160,
                      child: _indeterminate
                          ? const LinearProgressIndicator()
                          : LinearProgressIndicator(value: _progress),
                    ),
                    if (_progressString != null && !_indeterminate)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(_progressString!,
                            style: const TextStyle(fontSize: 11)),
                      ),
                  ],

                  const Spacer(),

                  // Gamemode chip — character's required mode
                  if (charGameMode.isNotEmpty)
                    Tooltip(
                      message: hasMismatch
                          ? 'Character needs "$charGameMode" but "$loadedMode" is loaded'
                          : sourcesLoaded
                              ? 'Gamemode: $charGameMode (sources loaded)'
                              : 'Gamemode: $charGameMode (no sources loaded)',
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasMismatch
                              ? Colors.orange.shade100
                              : !sourcesLoaded
                                  ? Colors.grey.shade200
                                  : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasMismatch
                                ? Colors.orange.shade600
                                : !sourcesLoaded
                                    ? Colors.grey.shade400
                                    : Colors.green.shade600,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasMismatch
                                  ? Icons.warning_amber_rounded
                                  : !sourcesLoaded
                                      ? Icons.circle_outlined
                                      : Icons.check_circle,
                              size: 13,
                              color: hasMismatch
                                  ? Colors.orange.shade700
                                  : !sourcesLoaded
                                      ? Colors.grey.shade600
                                      : Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              charGameMode,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: hasMismatch
                                    ? Colors.orange.shade800
                                    : !sourcesLoaded
                                        ? Colors.grey.shade700
                                        : Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Loaded sources mode label (when different from char mode)
                  if (loadedMode.isNotEmpty && charGameMode.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Sources: $loadedMode',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ),

                  const SizedBox(width: 4),

                  // Load status icon
                  if (_loadStatus != _LoadStatus.none)
                    Tooltip(
                      message:
                          '$_errorCount errors, $_warningCount warnings',
                      child: Icon(
                        _loadStatus == _LoadStatus.error
                            ? Icons.error
                            : _loadStatus == _LoadStatus.warning
                                ? Icons.warning
                                : Icons.check_circle,
                        color: _loadStatus == _LoadStatus.error
                            ? Colors.red
                            : _loadStatus == _LoadStatus.warning
                                ? Colors.orange
                                : Colors.green,
                        size: 16,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum _LoadStatus { none, ok, warning, error }
