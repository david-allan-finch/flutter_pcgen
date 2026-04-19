import 'campaign.dart';

/// A campaign that can be downloaded and installed via the PCGen installer.
///
/// Extends Campaign with version and destination information from install.lst files.
class InstallableCampaign extends Campaign {
  String? minVersion;
  String? maxVersion;
  String? minCvr;
  String? destDir;
}
