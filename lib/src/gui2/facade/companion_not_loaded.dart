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
// Translation of pcgen.gui2.facade.CompanionNotLoaded

import '../../core/race.dart';
import '../../facade/core/companion_facade.dart';
import '../../facade/util/default_reference_facade.dart';
import '../../facade/util/reference_facade.dart';

/// Represents a character's companion (familiar, animal companion, mount etc)
/// that is not currently loaded.
class CompanionNotLoaded implements CompanionFacade {
  final DefaultReferenceFacade<String> _nameRef;
  final DefaultReferenceFacade<String> _fileRef; // file path as String
  final DefaultReferenceFacade<Race> _raceRef;
  final String _companionType;

  CompanionNotLoaded(
      String name, String filePath, Race race, String companionType)
      : _nameRef = DefaultReferenceFacade(name),
        _fileRef = DefaultReferenceFacade(filePath),
        _raceRef = DefaultReferenceFacade(race),
        _companionType = companionType;

  @override
  ReferenceFacade<String> getNameRef() => _nameRef;

  @override
  ReferenceFacade<String> getFileRef() => _fileRef;

  @override
  ReferenceFacade<Race> getRaceRef() => _raceRef;

  @override
  String getCompanionType() => _companionType;
}
