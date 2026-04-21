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
// Translation of pcgen.gui2.facade.CompanionStub

import '../../core/race.dart';
import '../../facade/core/companion_stub_facade.dart';
import '../../facade/util/default_reference_facade.dart';
import '../../facade/util/reference_facade.dart';

/// Contains a definition of a possible companion (i.e. animal companion,
/// familiar, follower etc) for a character.
class CompanionStub implements CompanionStubFacade {
  final DefaultReferenceFacade<Race> _race;
  final String _companionType;

  CompanionStub(Race race, String companionType)
      : _race = DefaultReferenceFacade(race),
        _companionType = companionType;

  @override
  ReferenceFacade<Race> getRaceRef() => _race;

  @override
  String getCompanionType() => _companionType;

  @override
  String toString() => _race.toString();
}
