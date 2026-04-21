//
// Copyright James Dempsey, 2012
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.enumeration.BiographyField
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
