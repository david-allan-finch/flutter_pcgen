//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.application.DesktopHandler

import 'package:flutter/foundation.dart';

/// Handles desktop-integration actions: opening URLs, files, mail links.
/// On Flutter desktop, use url_launcher or similar packages.
class DesktopHandler {
  DesktopHandler._();

  static Future<void> openUrl(String url) async {
    // In a real implementation, use url_launcher:
    // await launchUrl(Uri.parse(url));
    debugPrint('DesktopHandler: open URL: $url');
  }

  static Future<void> openFile(String filePath) async {
    debugPrint('DesktopHandler: open file: $filePath');
  }

  static Future<void> sendMail(String address) async {
    debugPrint('DesktopHandler: send mail to: $address');
  }

  static bool isDesktopSupported() {
    // In Flutter, desktop support is available on Windows/macOS/Linux builds.
    return !kIsWeb;
  }
}
