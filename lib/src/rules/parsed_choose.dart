/// Structured representation of a CHOOSE: token from an LST file.
///
/// Common forms:
///   CHOOSE:NOCHOICE
///   CHOOSE:SKILL|TYPE=Dexterity|TYPE=Strength
///   CHOOSE:WEAPONPROFICIENCY|PC
///   CHOOSE:STRING|option1|option2|TITLE=Pick one
///   CHOOSE:NUMBER|MIN=1|MAX=5|TITLE=Bonus Amount
///   CHOOSE:CLASS|SPELLCASTER
library;

enum ChooseType {
  noChoice,
  skill,
  weaponProficiency,
  string,
  number,
  classType,
  feat,
  schools,
  unknown,
}

class ParsedChoose {
  final ChooseType type;

  /// For STRING: the list of fixed options.
  final List<String> options;

  /// For SKILL: type filters (e.g. ['Dexterity', 'Strength']) or [] = all.
  final List<String> skillTypeFilters;

  /// For NUMBER: min/max bounds.
  final int numberMin;
  final int numberMax;

  /// Dialog title to show the user.
  final String title;

  /// Raw value for unrecognised forms.
  final String raw;

  const ParsedChoose({
    required this.type,
    this.options = const [],
    this.skillTypeFilters = const [],
    this.numberMin = 1,
    this.numberMax = 20,
    this.title = '',
    this.raw = '',
  });

  bool get requiresSelection => type != ChooseType.noChoice;

  /// Parse a CHOOSE: token value (everything after 'CHOOSE:').
  static ParsedChoose parse(String value) {
    final upper = value.toUpperCase();

    if (upper == 'NOCHOICE') {
      return const ParsedChoose(type: ChooseType.noChoice);
    }

    // Split on '|' to get sub-tokens
    final parts = value.split('|');
    final typeTag = parts[0].trim().toUpperCase();

    String title = '';
    final options = <String>[];

    // Extract TITLE= if present
    final withoutTitle = parts.where((p) {
      if (p.toUpperCase().startsWith('TITLE=')) {
        title = p.substring(6);
        return false;
      }
      return true;
    }).toList();

    switch (typeTag) {
      case 'SKILL':
        final filters = <String>[];
        for (int i = 1; i < withoutTitle.length; i++) {
          final p = withoutTitle[i].trim();
          if (p.toUpperCase().startsWith('TYPE=')) {
            filters.add(p.substring(5));
          }
          // ALL, RANKS=, !RANKS= etc. ignored for now
        }
        return ParsedChoose(
          type: ChooseType.skill,
          skillTypeFilters: filters,
          title: title.isNotEmpty ? title : 'Choose a skill',
        );

      case 'WEAPONPROFICIENCY':
        return ParsedChoose(
          type: ChooseType.weaponProficiency,
          title: title.isNotEmpty ? title : 'Choose a weapon',
        );

      case 'STRING':
        for (int i = 1; i < withoutTitle.length; i++) {
          final p = withoutTitle[i].trim();
          if (p.isNotEmpty && !p.toUpperCase().startsWith('NUMCHOICES=')) {
            options.add(p);
          }
        }
        return ParsedChoose(
          type: ChooseType.string,
          options: options,
          title: title.isNotEmpty ? title : 'Choose an option',
        );

      case 'NUMBER':
      case 'NUMCHOICES=1':
        int min = 1, max = 20;
        final innerParts = value.split('|');
        for (final p in innerParts) {
          final pu = p.toUpperCase();
          if (pu.startsWith('MIN=')) min = int.tryParse(p.substring(4)) ?? min;
          if (pu.startsWith('MAX=')) max = int.tryParse(p.substring(4)) ?? max;
        }
        return ParsedChoose(
          type: ChooseType.number,
          numberMin: min,
          numberMax: max,
          title: title.isNotEmpty ? title : 'Choose a number',
        );

      case 'CLASS':
        return ParsedChoose(
          type: ChooseType.classType,
          title: title.isNotEmpty ? title : 'Choose a class',
        );

      case 'FEAT':
        return ParsedChoose(
          type: ChooseType.feat,
          title: title.isNotEmpty ? title : 'Choose a feat',
        );

      case 'SCHOOLS':
        return ParsedChoose(
          type: ChooseType.string,
          options: const [
            'Abjuration', 'Conjuration', 'Divination', 'Enchantment',
            'Evocation', 'Illusion', 'Necromancy', 'Transmutation',
          ],
          title: title.isNotEmpty ? title : 'Choose a school',
        );

      default:
        // Handle NUMCHOICES=1|SKILL|ALL and similar compound forms
        if (upper.startsWith('NUMCHOICES=')) {
          // Recurse on the remainder
          final rest = parts.skip(1).join('|');
          return parse(rest.isEmpty ? 'NOCHOICE' : rest);
        }
        return ParsedChoose(
          type: ChooseType.unknown,
          raw: value,
          title: title.isNotEmpty ? title : 'Choose',
        );
    }
  }
}
