// Translation of pcgen.gui2.converter.panel.CampaignPanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// Wizard step: select which campaigns (source sets) to convert.
class CampaignPanel extends ConvertSubPanel {
  final List<String> campaigns;

  const CampaignPanel({super.key, required this.campaigns});

  @override
  bool get isComplete => true;

  @override
  State<CampaignPanel> createState() => _CampaignPanelState();
}

class _CampaignPanelState extends ConvertSubPanelState<CampaignPanel> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Campaigns',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Choose the campaigns you want to convert:'),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _selected.addAll(widget.campaigns)),
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: const Text('Select None'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: widget.campaigns
                  .map((c) => CheckboxListTile(
                        value: _selected.contains(c),
                        title: Text(c),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selected.add(c);
                            } else {
                              _selected.remove(c);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
