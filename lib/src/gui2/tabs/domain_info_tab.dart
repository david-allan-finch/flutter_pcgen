// Translation of pcgen.gui2.tabs.DomainInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class DomainInfoTab extends StatefulWidget {
  const DomainInfoTab({super.key});

  @override
  State<DomainInfoTab> createState() => DomainInfoTabState();
}

class DomainInfoTabState extends State<DomainInfoTab> {
  dynamic _character;
  Deity? _selectedDeity;
  final TextEditingController _search = TextEditingController();

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DataSet?>(
      valueListenable: loadedDataSet,
      builder: (context, dataset, _) {
        return ValueListenableBuilder(
          valueListenable: currentCharacter,
          builder: (context, character, _) {
            final deities = dataset?.deities ?? const <Deity>[];
            final domains = dataset?.domains ?? const <Domain>[];
            return _buildContent(character, deities, domains);
          },
        );
      },
    );
  }

  Widget _buildContent(dynamic character, List<Deity> deities, List<Domain> domains) {
    final selectedDomainKeys = character != null ? _getDomainKeys(character) : const <String>[];
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? domains
        : domains.where((d) => d.getDisplayName().toLowerCase().contains(query)).toList();

    // Current deity key
    String deityKey = '';
    try { deityKey = (character as dynamic).getDeityKey() as String? ?? ''; } catch (_) {}

    return Column(
      children: [
        // Deity selector
        if (deities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text('Deity:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    // Guard: set to null if the key isn't found in the list
                    value: deityKey.isEmpty ||
                            !deities.any((d) => d.getKeyName() == deityKey)
                        ? null
                        : deityKey,
                    hint: deityKey.isNotEmpty &&
                            !deities.any((d) => d.getKeyName() == deityKey)
                        ? Text(deityKey, overflow: TextOverflow.ellipsis)
                        : const Text('— Select Deity —'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('(None)')),
                      ...deities.map((d) => DropdownMenuItem(
                            value: d.getKeyName(),
                            child: Text(d.getDisplayName()),
                          )),
                    ],
                    onChanged: character == null
                        ? null
                        : (v) {
                            try { (character as dynamic).setDeityKey(v ?? ''); } catch (_) {}
                            currentCharacter.notifyListeners();
                            setState(() {});
                          },
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 1),
        // Domain search
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter domains…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        // Domain list (left) + selected (right)
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text('Available Domains (${filtered.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No domains loaded.'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final domain = filtered[i];
                                final isSelected = selectedDomainKeys.contains(domain.getKeyName());
                                return ListTile(
                                  dense: true,
                                  title: Text(domain.getDisplayName(),
                                      style: const TextStyle(fontSize: 12)),
                                  tileColor: isSelected ? Colors.green.withOpacity(0.07) : null,
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                                      : null,
                                  onTap: character == null
                                      ? null
                                      : () {
                                          if (isSelected) {
                                            _removeDomain(character, domain.getKeyName());
                                          } else {
                                            _addDomain(character, domain.getKeyName());
                                          }
                                        },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text('Selected Domains (${selectedDomainKeys.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(
                      child: selectedDomainKeys.isEmpty
                          ? const Center(
                              child: Text('No domains selected.',
                                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                          : ListView.builder(
                              itemCount: selectedDomainKeys.length,
                              itemBuilder: (context, i) {
                                final key = selectedDomainKeys[i];
                                final domain = domains
                                    .where((d) => d.getKeyName() == key)
                                    .firstOrNull;
                                return ListTile(
                                  dense: true,
                                  title: Text(domain?.getDisplayName() ?? key,
                                      style: const TextStyle(fontSize: 12)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        size: 16, color: Colors.red),
                                    onPressed: character == null
                                        ? null
                                        : () => _removeDomain(character, key),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _getDomainKeys(dynamic character) {
    try { return (character as dynamic).getSelectedDomainKeys() as List<String>? ?? []; }
    catch (_) { return []; }
  }

  void _addDomain(dynamic character, String key) {
    try { (character as dynamic).addDomainKey(key); currentCharacter.notifyListeners(); setState(() {}); }
    catch (_) {}
  }

  void _removeDomain(dynamic character, String key) {
    try { (character as dynamic).removeDomainKey(key); currentCharacter.notifyListeners(); setState(() {}); }
    catch (_) {}
  }
}
