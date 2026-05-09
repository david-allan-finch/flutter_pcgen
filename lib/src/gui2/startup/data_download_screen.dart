// Shown on first launch (or when data is out of date) on Android/iOS.
// Downloads and extracts the PCGen system/data zip, then calls [onComplete].

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/startup/data_manager.dart';

class DataDownloadScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const DataDownloadScreen({super.key, required this.onComplete});

  @override
  State<DataDownloadScreen> createState() => _DataDownloadScreenState();
}

class _DataDownloadScreenState extends State<DataDownloadScreen> {
  final _mgr = DataManager();

  double? _progress;   // null = indeterminate
  String  _status = 'Ready to download';
  bool    _downloading = false;
  String? _error;

  Future<void> _startDownload() async {
    setState(() { _downloading = true; _error = null; _status = 'Starting…'; });
    try {
      await _mgr.downloadAndExtract(
        onProgress: (p, s) {
          if (mounted) setState(() { _progress = p; _status = s; });
        },
      );
      await _mgr.configureDataRoot();
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = e.toString();
          _status = 'Download failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2A1B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / title
              Image.asset('assets/images/pcgen_logo.png', width: 96, height: 96,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shield,
                      size: 96, color: Colors.green)),
              const SizedBox(height: 24),
              const Text('PCGen',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Game data files are required to run PCGen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('Size: ~${_estimatedSizeMb()} MB  •  Wi-Fi recommended',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 48),

              // Progress
              if (_downloading) ...[
                if (_progress != null)
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  )
                else
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                const SizedBox(height: 12),
                Text(_status,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ] else ...[
                // Error display
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent,
                            fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                  ),
                  icon: const Icon(Icons.download),
                  label: Text(_error != null ? 'Retry Download' : 'Download Game Data'),
                  onPressed: _startDownload,
                ),
              ],

              const SizedBox(height: 48),
              const Text(
                'Game data is stored in your device\'s private app storage '
                'and is not shared with other apps.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _estimatedSizeMb() {
    // Rough estimate — update if you know the actual zip size.
    return '80–120';
  }
}
