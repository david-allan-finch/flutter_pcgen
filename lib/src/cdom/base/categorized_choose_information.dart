//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.base.CategorizedChooseInformation
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/cdom/base/categorized.dart';
import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_driver.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_information.dart';
import 'package:flutter_pcgen/src/cdom/base/chooser.dart';
import 'package:flutter_pcgen/src/cdom/base/categorized_chooser.dart';
import 'package:flutter_pcgen/src/cdom/base/primitive_choice_set.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_information_utilities.dart';

// CategorizedChooseInformation is like BasicChooseInformation but is aware of
// a Category, delegating to CategorizedChooser when decoding.
class CategorizedChooseInformation<T extends Categorized<T>>
    implements ChooseInformation<T> {
  final PrimitiveChoiceSet<T> _pcs;
  final CDOMSingleRef<Category<T>> _category;
  final String _setName;
  String? _title;
  Chooser<T>? _choiceActor;

  CategorizedChooseInformation(
      String name, CDOMSingleRef<Category<T>> cat, PrimitiveChoiceSet<T> choice)
      : _setName = name,
        _category = cat,
        _pcs = choice;

  @override
  void setChoiceActor(dynamic actor) {
    _choiceActor = actor as Chooser<T>;
  }

  @override
  String encodeChoice(T item) => _choiceActor!.encodeChoice(item);

  @override
  T decodeChoice(dynamic context, String persistentFormat) {
    final actor = _choiceActor;
    if (actor is CategorizedChooser<T>) {
      return actor.decodeChoiceWithCategory(context, persistentFormat, _category.get()!);
    }
    return actor!.decodeChoice(context, persistentFormat);
  }

  @override
  dynamic getChoiceActor() => _choiceActor;

  @override
  bool operator ==(Object obj) {
    if (obj is CategorizedChooseInformation) {
      if (_title != obj._title) return false;
      return _setName == obj._setName &&
          _category == obj._category &&
          _pcs == obj._pcs;
    }
    return false;
  }

  @override
  int get hashCode => _setName.hashCode + 29;

  @override
  String getLSTformat([bool useAny = false]) => _pcs.getLSTformat(false);

  @override
  Type getReferenceClass() => _category.get()!.getReferenceClass();

  @override
  List<T> getSet(dynamic pc, [dynamic driver]) {
    return List.unmodifiable(_pcs.getSet(pc));
  }

  @override
  String getName() => _setName;

  void setTitle(String choiceTitle) {
    _title = choiceTitle;
  }

  @override
  String getTitle() => _title ?? getName();

  @override
  GroupingState getGroupingState() => _pcs.getGroupingState();

  CDOMSingleRef<Category<T>> getCategory() => _category;

  @override
  void restoreChoice(dynamic pc, dynamic owner, T item) {
    _choiceActor!.restoreChoice(pc, owner as ChooseDriver, item);
  }

  // stub: GUI chooser manager creation
  dynamic getChoiceManager(ChooseDriver owner, int cost) {
    // stub
    return null;
  }

  String composeDisplay(List<T> collection) {
    return ChooseInformationUtilities.buildEncodedString(collection);
  }

  void removeChoice(dynamic pc, ChooseDriver owner, T item) {
    _choiceActor!.removeChoice(pc, owner, item);
  }

  @override
  String getPersistentFormat() => _category.get()!.getPersistentFormat();

  @override
  bool allowsPersistentStorage() => true;
}
