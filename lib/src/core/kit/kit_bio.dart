import '../kit.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitBio extends BaseKit {
  String? _characterName;
  int? _characterAge;
  List<String>? _genderNames; // gender name strings
  String? _selectedGender;

  void setCharacterName(String name) { _characterName = name; }
  String? getCharacterName() => _characterName;

  void setCharacterAge(int age) { _characterAge = age; }
  int? getCharacterAge() => _characterAge;

  void addGender(String gender) {
    _genderNames ??= [];
    if (_genderNames!.contains(gender)) throw ArgumentError('Cannot add Gender: $gender twice');
    _genderNames!.add(gender);
  }

  List<String>? getGenders() => _genderNames;

  @override
  void apply(PlayerCharacter aPC) {
    if (_characterName != null) aPC.setName(_characterName!);
    if (_characterAge != null) aPC.setAge(_characterAge!);
    if (_selectedGender != null) aPC.setGender(_selectedGender!);
  }

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _selectedGender = null;
    if (_genderNames != null && _genderNames!.isNotEmpty) {
      _selectedGender = _genderNames![0]; // single or first option
    }
    apply(aPC);
    return true;
  }

  @override
  String getObjectName() => 'Bio Settings';

  @override
  String toString() {
    final buf = StringBuffer();
    if (_characterName != null) buf.write(' Name: $_characterName');
    if (_genderNames != null) buf.write(' Gender: ${_genderNames!.join(', ')}');
    if (_characterAge != null) buf.write(' Age: $_characterAge');
    return buf.toString();
  }
}
