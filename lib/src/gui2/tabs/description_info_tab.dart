// Translation of pcgen.gui2.tabs.DescriptionInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class DescriptionInfoTab extends StatefulWidget {
  const DescriptionInfoTab({super.key});

  @override
  State<DescriptionInfoTab> createState() => DescriptionInfoTabState();
}

class DescriptionInfoTabState extends State<DescriptionInfoTab>
    with SingleTickerProviderStateMixin {
  dynamic _character;
  late final TabController _tabController;

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _appearanceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    _appearanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        _syncControllers(character);
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Biography'),
                Tab(text: 'Appearance'),
                Tab(text: 'Notes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTextPane(
                    character: character,
                    controller: _bioController,
                    hint: 'Enter character biography…',
                    onSave: (v) {
                      try { (character as dynamic).setBiography(v); } catch (_) {}
                    },
                  ),
                  _buildTextPane(
                    character: character,
                    controller: _appearanceController,
                    hint: 'Describe your character\'s appearance…',
                    onSave: (v) {
                      try { (character as dynamic).setAppearance(v); } catch (_) {}
                    },
                  ),
                  _buildTextPane(
                    character: character,
                    controller: _notesController,
                    hint: 'Session notes, backstory details…',
                    onSave: (v) {
                      try { (character as dynamic).setNotes2(v); } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _syncControllers(dynamic character) {
    if (character == null) return;
    try {
      final bio = (character as dynamic).getBiography() as String? ?? '';
      if (_bioController.text != bio) _bioController.text = bio;
      final appearance = (character as dynamic).getAppearance() as String? ?? '';
      if (_appearanceController.text != appearance) _appearanceController.text = appearance;
      final notes = (character as dynamic).getNotes() as String? ?? '';
      if (_notesController.text != notes) _notesController.text = notes;
    } catch (_) {}
  }

  Widget _buildTextPane({
    required dynamic character,
    required TextEditingController controller,
    required String hint,
    required void Function(String) onSave,
  }) {
    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hint,
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Save'),
              onPressed: () {
                onSave(controller.text);
                currentCharacter.notifyListeners();
              },
            ),
          ),
        ],
      ),
    );
  }
}
