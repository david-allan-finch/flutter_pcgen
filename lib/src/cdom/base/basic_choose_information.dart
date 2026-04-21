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
// Translation of pcgen.cdom.base.BasicChooseInformation
import '../enumeration/grouping_state.dart';
import 'choose_information.dart';
import 'choose_driver.dart';
import 'chooser.dart';
import 'primitive_choice_set.dart';
import 'choose_information_utilities.dart';

// BasicChooseInformation holds a PrimitiveChoiceSet and a Chooser, implementing
// the ChooseInformation contract for the CHOOSE token system.
class BasicChooseInformation<T> implements ChooseInformation<T> {
  final PrimitiveChoiceSet<T> _pcs;
  final String _setName;
  String? _title;
  Chooser<T>? _choiceActor;
  final String _persistentFormat;

  BasicChooseInformation(String name, PrimitiveChoiceSet<T> choice, String persistentFormat)
      : _setName = name,
        _pcs = choice,
        _persistentFormat = persistentFormat;

  @override
  void setChoiceActor(dynamic actor) {
    _choiceActor = actor as Chooser<T>;
  }

  @override
  String encodeChoice(T item) {
    return _choiceActor!.encodeChoice(item);
  }

  @override
  T decodeChoice(dynamic context, String persistenceFormat) {
    return _choiceActor!.decodeChoice(context, persistenceFormat);
  }

  @override
  dynamic getChoiceActor() => _choiceActor;

  @override
  bool operator ==(Object obj) {
    if (obj is BasicChooseInformation) {
      if (_title != obj._title) return false;
      return _setName == obj._setName && _pcs == obj._pcs;
    }
    return false;
  }

  @override
  int get hashCode => _setName.hashCode + 29;

  @override
  String getLSTformat() => _pcs.getLSTformat(false);

  @override
  Type getReferenceClass() => _pcs.getChoiceClass();

  @override
  List<T> getSet(dynamic pc, [dynamic driver]) {
    return _pcs.getSet(pc).toList();
  }

  @override
  String getName() => _setName;

  void setTitle(String choiceTitle) {
    _title = choiceTitle;
  }

  @override
  String? getTitle() => _title;

  @override
  GroupingState getGroupingState() => _pcs.getGroupingState();

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
  String getPersistentFormat() => _persistentFormat;

  @override
  bool allowsPersistentStorage() => true;
}
