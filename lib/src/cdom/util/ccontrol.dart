// Code Control constants — control which internal variable/channel is active
// for a given game system feature.
final class CControl {
  // String-only controls (simple on/off feature switches or variable names)
  static const String critmult = 'CRITMULT';
  static const String critrange = 'CRITRANGE';
  static const String legs = 'LEGS';
  static const String creaturehands = 'CREATUREHANDS';
  static const String fumblerange = 'FUMBLERANGE';
  static const String althp = 'ALTHP';
  static const String eqmaxdex = 'EQMAXDEX';
  static const String pcmaxdex = 'PCMAXDEX';
  static const String eqaccheck = 'EQACCHECK';
  static const String pcaccheck = 'PCACCHECK';
  static const String eqspellfailure = 'EQSPELLFAILURE';
  static const String pcspellfailure = 'PCSPELLFAILURE';
  static const String edr = 'EDR';
  static const String eqrange = 'EQRANGE';
  static const String sizemoddefense = 'SIZEMODDEFENSE';
  static const String eqbaseacmod = 'EQBASEACMOD';
  static const String eqacmod = 'EQACMOD';
  static const String altersac = 'ALTERSAC';
  static const String acvartotal = 'ACVARTOTAL';
  static const String acvararmor = 'ACVARARMOR';
  static const String eqreach = 'EQREACH';
  static const String pcreach = 'PCREACH';
  static const String initiative = 'INITIATIVE';
  static const String initiativestat = 'INITIATIVESTAT';
  static const String initiativemisc = 'INITIATIVEMISC';
  static const String initiativebonus = 'INITIATIVEBONUS';
  static const String statinput = 'STATINPUT';
  static const String basesave = 'BASESAVE';
  static const String totalsave = 'TOTALSAVE';
  static const String miscsave = 'MISCSAVE';
  static const String epicsave = 'EPICSAVE';
  static const String magicsave = 'MAGICSAVE';
  static const String statmodsave = 'STATMODSAVE';
  static const String racesave = 'RACESAVE';
  static const String basesize = 'BASESIZE';
  static const String pcsize = 'PCSIZE';
  static const String weaponhands = 'WEAPONHANDS';
  static const String weightmultiplier = 'WEIGHTMULTIPLIER';
  static const String wieldcat = 'WIELDCAT';
  static const String costmultiplier = 'COSTMULTIPLIER';
  static const String alignmentfeature = 'ALIGNMENTFEATURE';
  static const String domainfeature = 'DOMAINFEATURE';

  // Channel-type controls (full CControl objects with metadata)
  static final CControl face = CControl._('FACE', 'Face', null, 'ORDEREDPAIR');
  static final CControl ageinput = CControl._('AGEINPUT', 'Age', null, 'NUMBER', isChannel: true, isAutoGranted: false);
  static final CControl alignmentinput = CControl._('ALIGNMENTINPUT', 'Alignment', alignmentfeature, 'ALIGNMENT', isChannel: true, isAutoGranted: true);
  static final CControl charactertype = CControl._('CHARACERTYPE', 'CharacterType', null, 'STRING', isChannel: true, isAutoGranted: false);
  static final CControl deityinput = CControl._('DEITYINPUT', 'Deity', domainfeature, 'DEITY', isChannel: true, isAutoGranted: true);
  static final CControl goldinput = CControl._('GOLDINPUT', 'Gold', null, 'NUMBER', isChannel: true, isAutoGranted: false);
  static final CControl haircolorinput = CControl._('HAIRCOLORINPUT', 'HairColor', null, 'STRING', isChannel: true, isAutoGranted: false);
  static final CControl hairstyleinput = CControl._('HAIRSTYLEINPUT', 'HairStyle', null, 'STRING', isChannel: true, isAutoGranted: false);
  static final CControl handedinput = CControl._('HANDEDINPUT', 'Handed', null, 'HANDED', isChannel: true, isAutoGranted: false);
  static final CControl availhandedness = CControl._('AVAILHANDEDNESS', 'AvailableHandedness', null, 'ARRAY[HANDED]', isChannel: true, isAutoGranted: false);
  static final CControl heightinput = CControl._('HEIGHTINPUT', 'Height', null, 'NUMBER', isChannel: true, isAutoGranted: false);
  static final CControl skincolorinput = CControl._('SKINCOLORINPUT', 'SkinColor', null, 'STRING', isChannel: true, isAutoGranted: false);

  final String name;
  final String defaultValue;
  final String? controllingFeature;
  final String format;
  final bool isChannel;
  final bool isAutoGranted;

  CControl._(this.name, this.defaultValue, this.controllingFeature, this.format,
      {this.isChannel = false, this.isAutoGranted = false});

  String getName() => name;
  String getDefaultValue() => defaultValue;
  String? getControllingFeature() => controllingFeature;
  String getFormat() => format;
}
