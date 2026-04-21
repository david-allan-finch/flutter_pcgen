//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.ChooseDriver
import 'choose_selection_actor.dart';
import 'choose_information.dart';

// A ChooseDriver is an object that drives the CHOOSE mechanism (e.g. a
// CDOMObject with a CHOOSE token). It provides all the information needed
// to present and apply selections.
abstract interface class ChooseDriver {
  ChooseInformation<dynamic> getChooseInfo();
  dynamic getSelectFormula(); // Formula
  List<ChooseSelectionActor<dynamic>> getActors();
  String getFormulaSource();
  dynamic getNumChoices(); // Formula
  String getDisplayName();
}
