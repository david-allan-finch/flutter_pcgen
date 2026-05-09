// First-launch data selection screen.
// Shown when no data packs are installed. User picks which packs to download.

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/startup/data_manager.dart';
import 'package:flutter_pcgen/src/gui2/startup/pack_metadata.dart';

class DataDownloadScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const DataDownloadScreen({super.key, required this.onComplete});

  @override
  State<DataDownloadScreen> createState() => _DataDownloadScreenState();
}

class _DataDownloadScreenState extends State<DataDownloadScreen> {
  final _mgr = DataManager();

  // Selected packs for download
  final Set<String> _selected = {};

  // Per-pack download state
  final Map<String, _DlState> _states = {};

  bool get _anyDownloading => _states.values.any((s) => !s.done && s.error == null);
  bool get _allSelectedDone =>
      _selected.isNotEmpty && _selected.every((id) => _states[id]?.done == true);

  Future<void> _downloadSelected() async {
    for (final entry in DataManager.catalogue) {
      if (!_selected.contains(entry.metadata.id)) continue;
      if (_states[entry.metadata.id]?.done == true) continue;

      setState(() => _states[entry.metadata.id] = _DlState(null, 'Starting…'));
      try {
        await _mgr.downloadAndInstall(
          entry.url,
          onProgress: (p, s) {
            if (mounted) setState(() => _states[entry.metadata.id] = _DlState(p, s));
          },
        );
        if (mounted) setState(() => _states[entry.metadata.id] = _DlState(1.0, 'Done', done: true));
      } catch (e) {
        if (mounted) setState(() =>
            _states[entry.metadata.id] = _DlState(null, 'Failed', error: e.toString()));
      }
    }
    if (_allSelectedDone) {
      await _mgr.configureDataRoot();
      if (mounted) widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2A1B),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                children: [
                  Image.asset('assets/images/pcgen_logo.png', width: 72, height: 72,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.shield, size: 72, color: Colors.green)),
                  const SizedBox(height: 16),
                  const Text('Welcome to PCGen',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose the game data packs you want to install.\n'
                    'You can add more later from Settings › Data Packs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Pack list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: DataManager.catalogue.map(_buildPackCard).toList(),
              ),
            ),

            // Bottom action
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_anyDownloading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Downloading — keep the app open…',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: _anyDownloading
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.download),
                      label: Text(_anyDownloading
                          ? 'Downloading…'
                          : _allSelectedDone
                              ? 'Continue'
                              : 'Install Selected (${_selected.length})'),
                      onPressed: _selected.isEmpty || _anyDownloading
                          ? null
                          : _allSelectedDone
                              ? () async {
                                  await _mgr.configureDataRoot();
                                  widget.onComplete();
                                }
                              : _downloadSelected,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackCard(CatalogueEntry entry) {
    final m = entry.metadata;
    final ds = _states[m.id];
    final isSelected = _selected.contains(m.id);

    return Card(
      color: isSelected ? Colors.green.withOpacity(0.15) : Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: ds?.done == true || _anyDownloading ? null : () {
          setState(() {
            if (isSelected) _selected.remove(m.id);
            else _selected.add(m.id);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(m.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: Colors.white))),
                if (ds == null)
                  Checkbox(
                    value: isSelected,
                    activeColor: Colors.green,
                    onChanged: _anyDownloading ? null : (v) {
                      setState(() {
                        if (v == true) _selected.add(m.id);
                        else _selected.remove(m.id);
                      });
                    },
                  )
                else if (ds.done)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (ds.error != null)
                  const Icon(Icons.error_outline, color: Colors.red)
                else
                  const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)),
              ]),
              if (m.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(m.description!,
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${entry.sizeMb}  •  v${m.version}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ),
              // Progress bar
              if (ds != null && !ds.done && ds.error == null) ...[
                const SizedBox(height: 10),
                ds.progress != null
                    ? LinearProgressIndicator(value: ds.progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.green))
                    : const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(Colors.green)),
                const SizedBox(height: 4),
                Text(ds.status,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
              if (ds?.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(ds!.error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DlState {
  final double? progress;
  final String status;
  final bool done;
  final String? error;
  const _DlState(this.progress, this.status, {this.done = false, this.error});
}
