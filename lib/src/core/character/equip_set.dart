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
// Translation of pcgen.core.character.EquipSet
import '../equipment.dart';
import '../player_character.dart';

// An equipment set node — each piece of equipped gear with hierarchical path IDs.
// Path format: "0.1.3" where 0=root, 1=parent id, 3=this id.
final class EquipSet implements Comparable<EquipSet> {
  static const String defaultSetPath = '0.1';
  static const String pathSep = '.';

  String idPath;
  String name;
  String value;
  String note;
  Equipment? eqItem;
  double qty;
  bool useTempBonuses;

  EquipSet(this.idPath, this.name, {this.value = '', this.note = '', this.eqItem, this.qty = 1.0, this.useTempBonuses = true});

  static int getIdFromPath(String path) {
    if (path.isEmpty) return 0;
    final parts = path.split(pathSep);
    return int.tryParse(parts.last) ?? 0;
  }

  static String getParentPath(String path) {
    final idx = path.lastIndexOf(pathSep);
    if (idx < 0) return '';
    return path.substring(0, idx);
  }

  static int getPathDepth(String path) => path.split(pathSep).length;

  int getId() => getIdFromPath(idPath);

  String getParentIdPath() {
    final parts = idPath.split(pathSep);
    if (parts.length < 2) return '';
    return parts.sublist(0, parts.length - 1).join(pathSep);
  }

  String getRootIdPath() {
    final parts = idPath.split(pathSep);
    if (parts.length < 2) return '';
    return '${parts[0]}$pathSep${parts[1]}';
  }

  bool isPartOf(String rootId) {
    final abCalcId = '$rootId$pathSep';
    final abParentId = '${getParentIdPath()}$pathSep';
    return abParentId.startsWith(abCalcId);
  }

  void equipItem(PlayerCharacter aPC) {
    final eq = eqItem;
    if (eq == null) return;
    final parts = idPath.split(pathSep);
    if (parts.length > 3) {
      // contained item — use root set's location
      final rootPath = parts.sublist(0, 3).join(pathSep);
      final rootSet = aPC.getEquipSetByIdPath(rootPath);
      if (rootSet != null && rootSet.name.startsWith('Carried')) {
        eq.addEquipmentToLocation(qty, 'CARRIED_NEITHER', false, aPC);
      } else if (rootSet != null && rootSet.name.startsWith('Not Carried')) {
        eq.addEquipmentToLocation(qty, 'NOT_CARRIED', false, aPC);
      } else if (rootSet != null && rootSet.name.startsWith('Equipped')) {
        eq.addEquipmentToLocation(qty, 'EQUIPPED_NEITHER', false, aPC);
      } else {
        eq.addEquipmentToLocation(qty, 'CONTAINED', false, aPC);
      }
    } else if (name.startsWith('Carried')) {
      eq.addEquipmentToLocation(qty, 'CARRIED_NEITHER', false, aPC);
    } else if (name.startsWith('Not Carried')) {
      eq.addEquipmentToLocation(qty, 'NOT_CARRIED', false, aPC);
    } else {
      eq.addEquipmentToLocation(qty, 'EQUIPPED_NEITHER', true, aPC);
    }
  }

  void addNoteToItem() {
    if (note.isNotEmpty) eqItem?.note = note;
  }

  EquipSet clone() => EquipSet(
    idPath, name,
    value: value, note: note,
    eqItem: eqItem?.clone(),
    qty: qty, useTempBonuses: useTempBonuses,
  );

  @override
  int compareTo(EquipSet obj) => idPath.toLowerCase().compareTo(obj.idPath.toLowerCase());

  @override
  String toString() => name;
}
