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
