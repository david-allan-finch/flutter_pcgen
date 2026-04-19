// Translation of pcgen.persistence.lst.InstallLoader

import '../../core/installable_campaign.dart';
import 'lst_line_file_loader.dart';

/// Loads install.lst files from a campaign directory.
///
/// The install.lst file describes how a campaign data set should be installed
/// (min/max PCGen version, dest folder, etc.). Parsed into an [InstallableCampaign].
class InstallLoader extends LstLineFileLoader {
  InstallableCampaign? _campaign;

  InstallableCampaign? getCampaign() => _campaign;

  @override
  Future<void> loadLstFile(dynamic context, Uri source) async {
    _campaign = InstallableCampaign();
    await super.loadLstFile(context, source);
  }

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;
    if (_campaign == null) return;

    final colonIdx = lstLine.indexOf(':');
    if (colonIdx <= 0) return;

    final key = lstLine.substring(0, colonIdx).trim();
    final value = lstLine.substring(colonIdx + 1).trim();

    switch (key) {
      case 'MINVERSION':
        _campaign!.minVersion = value;
      case 'MAXVERSION':
        _campaign!.maxVersion = value;
      case 'MINCVR':
        _campaign!.minCvr = value;
      case 'DEST':
        _campaign!.destDir = value;
      default:
        break;
    }
  }
}
