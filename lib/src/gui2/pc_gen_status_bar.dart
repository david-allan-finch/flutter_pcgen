// Translation of pcgen.gui2.PCGenStatusBar

import 'package:flutter/material.dart';

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
    return Container(
      height: 24,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          if (_contextMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(_contextMessage!, style: const TextStyle(fontSize: 12)),
            ),
          const Spacer(),
          if (_progressVisible)
            SizedBox(
              width: 200,
              child: _indeterminate
                  ? const LinearProgressIndicator()
                  : LinearProgressIndicator(value: _progress),
            ),
          if (_progressString != null && !_indeterminate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(_progressString!, style: const TextStyle(fontSize: 11)),
            ),
          const Spacer(),
          if (_loadStatus != _LoadStatus.none)
            Tooltip(
              message: '$_errorCount errors and $_warningCount warnings occurred',
              child: IconButton(
                iconSize: 16,
                icon: Icon(
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
                onPressed: () {
                  // Show debug/log dialog
                },
              ),
            ),
        ],
      ),
    );
  }
}

enum _LoadStatus { none, ok, warning, error }
