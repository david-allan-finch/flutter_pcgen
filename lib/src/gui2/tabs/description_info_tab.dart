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
  late final TabController _tabController;

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _appearanceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final FocusNode _bioFocus        = FocusNode();
  final FocusNode _appearanceFocus = FocusNode();
  final FocusNode _notesFocus      = FocusNode();

  // The last character whose values have been loaded into the controllers.
  // We only resync when the character identity changes, not on every rebuild.
  Object? _lastSyncedCharacter;

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
    _bioFocus.dispose();
    _appearanceFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  void _syncIfCharacterChanged(dynamic character) {
    if (character == null) { _lastSyncedCharacter = null; return; }
    // Only reload controllers when a different character is selected.
    if (identical(character, _lastSyncedCharacter)) return;
    _lastSyncedCharacter = character as Object;
    _forceSync(character);
  }

  void _forceSync(dynamic character) {
    try {
      _bioController.text        = (character as dynamic).getBiography()  as String? ?? '';
      _appearanceController.text = (character as dynamic).getAppearance() as String? ?? '';
      _notesController.text      = (character as dynamic).getNotes()       as String? ?? '';
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        // Only resync when the character object itself changes, not on every
        // notifyListeners call. This prevents overwriting text the user is
        // actively editing on the current character.
        _syncIfCharacterChanged(character);

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
                    focusNode: _bioFocus,
                    hint: 'Enter character biography…',
                    onSave: (v) {
                      try { (character as dynamic).setBiography(v); } catch (_) {}
                    },
                  ),
                  _buildTextPane(
                    character: character,
                    controller: _appearanceController,
                    focusNode: _appearanceFocus,
                    hint: "Describe your character's appearance…",
                    onSave: (v) {
                      try { (character as dynamic).setAppearance(v); } catch (_) {}
                    },
                  ),
                  _buildTextPane(
                    character: character,
                    controller: _notesController,
                    focusNode: _notesFocus,
                    hint: 'Session notes, backstory details…',
                    onSave: (v) {
                      try { (character as dynamic).setNotes(v); } catch (_) {}
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

  Widget _buildTextPane({
    required dynamic character,
    required TextEditingController controller,
    required FocusNode focusNode,
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
              focusNode: focusNode,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _forceSync(character),
                child: const Text('Revert'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save'),
                onPressed: () {
                  onSave(controller.text);
                  // Don't call notifyListeners here — it would trigger rebuilds
                  // in every other tab, which is noisy and unnecessary.
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
