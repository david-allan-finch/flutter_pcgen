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
// Translation of pcgen.core.ChronicleEntry
// A record of an event in the character's adventuring history.
class ChronicleEntry {
  bool outputEntry = true;
  String campaign = '';
  String adventure = '';
  String party = '';
  String date = '';
  int xpField = 0;
  String gmField = '';
  String chronicle = '';

  ChronicleEntry clone() => ChronicleEntry()
    ..outputEntry = outputEntry
    ..campaign = campaign
    ..adventure = adventure
    ..party = party
    ..date = date
    ..xpField = xpField
    ..gmField = gmField
    ..chronicle = chronicle;

  @override
  int get hashCode => Object.hash(adventure, campaign, chronicle, date, gmField, outputEntry, party, xpField);

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! ChronicleEntry) return false;
    return adventure == obj.adventure &&
        campaign == obj.campaign &&
        chronicle == obj.chronicle &&
        date == obj.date &&
        gmField == obj.gmField &&
        outputEntry == obj.outputEntry &&
        party == obj.party &&
        xpField == obj.xpField;
  }
}
