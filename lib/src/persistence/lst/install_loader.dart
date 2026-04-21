//
// Copyright 2007 (C) James Dempsey <jdempsey@users.sourceforge.net>
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
