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
