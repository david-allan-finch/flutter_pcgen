// Translation of pcgen.persistence.lst.TraitLoader

import '../../core/system_collections.dart';
import 'lst_line_file_loader.dart';

/// Loads trait/speech/phrase/phobia/interests/hair-style lists from .lst files.
///
/// The file is section-based: a header like [TRAIT], [SPEECH], [PHRASE],
/// [PHOBIA], [INTERESTS], or [HAIRSTYLE] sets the current section.
class TraitLoader extends LstLineFileLoader {
  int _traitType = -1;
  String _gameMode = '';

  void setGameMode(String gameMode) => _gameMode = gameMode;

  @override
  Future<void> loadLstFile(dynamic context, Uri source) async {
    _traitType = -1;
    await super.loadLstFile(context, source);
  }

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    if (!lstLine.startsWith('[')) {
      switch (_traitType) {
        case 0:
          SystemCollections.addToTraitList(lstLine.trim(), _gameMode);
        case 1:
          SystemCollections.addToSpeechList(lstLine.trim(), _gameMode);
        case 2:
          SystemCollections.addToPhraseList(lstLine.trim(), _gameMode);
        case 3:
          SystemCollections.addToPhobiaList(lstLine.trim(), _gameMode);
        case 4:
          SystemCollections.addToInterestsList(lstLine.trim(), _gameMode);
        case 5:
          SystemCollections.addToHairStyleList(lstLine.trim(), _gameMode);
        default:
          break;
      }
    } else {
      if (lstLine.startsWith('[TRAIT]')) {
        _traitType = 0;
      } else if (lstLine.startsWith('[SPEECH]')) {
        _traitType = 1;
      } else if (lstLine.startsWith('[PHRASE]')) {
        _traitType = 2;
      } else if (lstLine.startsWith('[PHOBIA]')) {
        _traitType = 3;
      } else if (lstLine.startsWith('[INTERESTS]')) {
        _traitType = 4;
      } else if (lstLine.startsWith('[HAIRSTYLE]')) {
        _traitType = 5;
      }
    }
  }
}
