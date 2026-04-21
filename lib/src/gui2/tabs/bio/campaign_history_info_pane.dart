// Translation of pcgen.gui2.tabs.bio.CampaignHistoryInfoPane

import 'package:flutter/material.dart';

/// Panel for recording a character's campaign history entries.
class CampaignHistoryInfoPane extends StatefulWidget {
  final dynamic character;

  const CampaignHistoryInfoPane({super.key, this.character});

  @override
  State<CampaignHistoryInfoPane> createState() => _CampaignHistoryInfoPaneState();
}

class _HistoryEntry {
  String campaign;
  String adventure;
  String party;
  String date;
  String experience;
  String gmName;
  String notes;
  _HistoryEntry({
    this.campaign = '',
    this.adventure = '',
    this.party = '',
    this.date = '',
    this.experience = '',
    this.gmName = '',
    this.notes = '',
  });
}

class _CampaignHistoryInfoPaneState extends State<CampaignHistoryInfoPane> {
  final List<_HistoryEntry> _entries = [];

  void _addEntry() {
    setState(() => _entries.add(_HistoryEntry()));
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (ctx, i) => _buildEntryCard(i),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
            onPressed: _addEntry,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(int index) {
    final e = _entries[index];
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _field('Campaign', e.campaign, (v) => e.campaign = v)),
                const SizedBox(width: 8),
                Expanded(child: _field('Adventure', e.adventure, (v) => e.adventure = v)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field('Party', e.party, (v) => e.party = v)),
                const SizedBox(width: 8),
                Expanded(child: _field('Date', e.date, (v) => e.date = v)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field('Experience', e.experience, (v) => e.experience = v)),
                const SizedBox(width: 8),
                Expanded(child: _field('GM Name', e.gmName, (v) => e.gmName = v)),
              ],
            ),
            _field('Notes', e.notes, (v) => e.notes = v, maxLines: 3),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Remove'),
                onPressed: () => _removeEntry(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, ValueChanged<String> onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: TextEditingController(text: value),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
