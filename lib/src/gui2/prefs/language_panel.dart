// Translation of pcgen.gui2.prefs.LanguagePanel

import 'package:flutter/material.dart';

/// Preferences panel for interface language/locale settings.
class LanguagePanel extends StatefulWidget {
  const LanguagePanel({super.key});

  @override
  State<LanguagePanel> createState() => _LanguagePanelState();
}

class _LanguagePanelState extends State<LanguagePanel> {
  String _language = 'en_US';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Language', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        DropdownButtonFormField<String>(
          value: _language,
          decoration: const InputDecoration(labelText: 'Interface Language'),
          items: const [
            DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
            DropdownMenuItem(value: 'de_DE', child: Text('Deutsch')),
            DropdownMenuItem(value: 'fr_FR', child: Text('Français')),
            DropdownMenuItem(value: 'es_ES', child: Text('Español')),
          ],
          onChanged: (v) => setState(() => _language = v ?? 'en_US'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Restart PCGen to apply language changes.',
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
        ),
      ],
    );
  }
}
