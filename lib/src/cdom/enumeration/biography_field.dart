// Lists the possible biographical fields that may be edited or suppressed from export.
enum BiographyField {
  name('in_nameLabel'),
  playerName('in_player'),
  gender('in_gender'),
  handed('in_handString'),
  alignment('in_alignString'),
  deity('in_deity'),
  age('in_age'),
  skinTone('in_appSkintoneColor'),
  hairColor('in_appHairColor'),
  hairStyle('in_style'),
  eyeColor('in_appEyeColor'),
  height('in_height'),
  weight('in_weight'),
  speechPattern('in_speech'),
  birthday('in_birthday'),
  location('in_location'),
  city('in_home'),
  region('in_region'),
  birthplace('in_birthplace'),
  personalityTrait1('in_personality1'),
  personalityTrait2('in_personality2'),
  phobias('in_phobias'),
  interests('in_interest'),
  catchPhrase('in_phrase');

  final String il8nKey;
  const BiographyField(this.il8nKey);

  String getIl8nKey() => il8nKey;
}
