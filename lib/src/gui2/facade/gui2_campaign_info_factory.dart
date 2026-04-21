//
// Copyright James Dempsey, 2011
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
// Translation of pcgen.gui2.facade.Gui2CampaignInfoFactory

/// Factory that produces display strings and info for campaign/source objects
/// in the GUI layer. Equivalent to Java's Gui2CampaignInfoFactory.
class Gui2CampaignInfoFactory {
  Gui2CampaignInfoFactory._();

  static String getHTMLInfo(dynamic campaign) {
    if (campaign == null) return '<html><body>No campaign selected</body></html>';
    final buf = StringBuffer('<html><body>');
    final name = _field(campaign, 'name');
    if (name.isNotEmpty) buf.write('<h3>$name</h3>');
    _appendField(buf, 'Publisher', campaign, 'publisher');
    _appendField(buf, 'Game System', campaign, 'gameSystem');
    _appendField(buf, 'Setting', campaign, 'setting');
    _appendField(buf, 'Genre', campaign, 'genre');
    _appendField(buf, 'Booktype', campaign, 'booktype');
    _appendField(buf, 'URL', campaign, 'url');
    _appendField(buf, 'Description', campaign, 'description');
    buf.write('</body></html>');
    return buf.toString();
  }

  static String getPublisher(dynamic campaign) => _field(campaign, 'publisher');
  static String getGameSystem(dynamic campaign) => _field(campaign, 'gameSystem');
  static String getSetting(dynamic campaign) => _field(campaign, 'setting');
  static String getGenre(dynamic campaign) => _field(campaign, 'genre');
  static String getBookType(dynamic campaign) => _field(campaign, 'booktype');
  static String getDescription(dynamic campaign) => _field(campaign, 'description');

  static String getStatus(dynamic campaign) {
    final status = _field(campaign, 'status');
    return status.isNotEmpty ? status : 'RELEASED';
  }

  static bool isLicensed(dynamic campaign) {
    if (campaign is Map) return campaign['licensed'] as bool? ?? false;
    return false;
  }

  static String getLicense(dynamic campaign) => _field(campaign, 'license');

  static String getCopyrightList(dynamic campaign) {
    if (campaign is Map) {
      final copyrights = campaign['copyrights'];
      if (copyrights is List) return copyrights.join('\n');
    }
    return '';
  }

  static List<String> getInfoList(dynamic campaign) {
    final buf = <String>[];
    if (campaign is Map) {
      void add(String label, String? value) {
        if (value != null && value.isNotEmpty) buf.add('$label: $value');
      }
      add('Name', campaign['name'] as String?);
      add('Publisher', campaign['publisher'] as String?);
      add('Game System', campaign['gameSystem'] as String?);
      add('Setting', campaign['setting'] as String?);
    }
    return buf;
  }

  static String _field(dynamic obj, String key) {
    if (obj is Map) return obj[key] as String? ?? '';
    return '';
  }

  static void _appendField(StringBuffer buf, String label, dynamic obj, String key) {
    final v = _field(obj, key);
    if (v.isNotEmpty) buf.write('<b>$label:</b> ${_esc(v)}<br>');
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
