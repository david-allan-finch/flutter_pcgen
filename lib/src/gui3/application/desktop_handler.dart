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
