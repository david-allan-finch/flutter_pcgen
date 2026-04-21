// Translation of pcgen.gui2.facade.EquipNode

import '../../core/body_structure.dart';
import '../../core/equipment.dart';
import '../../core/character/equip_slot.dart';
import '../../facade/core/equipment_facade.dart';

/// Represents a node in the equipping tree. It may be an item of equipment or
/// a slot that may be filled. EquipNode objects are immutable once created.
class EquipNode implements Comparable<EquipNode> {
  static String _fmt(int n) => n.toString().padLeft(2, '0');

  // --- Node types ---
  static const String nodeTypeBodySlot = 'BODY_SLOT';
  static const String nodeTypePhantomSlot = 'PHANTOM_SLOT';
  static const String nodeTypeEquipment = 'EQUIPMENT';

  final String nodeType;
  final BodyStructure bodyStructure;
  Equipment? equipment;
  EquipNode? parent;
  final String name;
  EquipSlot? slot;
  String? idPath;
  String? _order;
  bool singleOnly = false;

  /// Create a node representing a body structure.
  EquipNode.bodySlot(this.bodyStructure, int order)
      : nodeType = nodeTypeBodySlot,
        name = bodyStructure.toString(),
        _order = _fmt(order);

  /// Create a node representing an equipment slot (phantom slot).
  EquipNode.phantomSlot(EquipNode parentNode, this.slot, this.singleOnly)
      : nodeType = nodeTypePhantomSlot,
        bodyStructure = parentNode.bodyStructure,
        name = slot!.slotName,
        parent = parentNode;

  /// Create a node representing an equipped item of equipment.
  EquipNode.equipmentItem(
      EquipNode parentNode, this.slot, this.equipment, this.idPath)
      : nodeType = nodeTypeEquipment,
        bodyStructure = parentNode.bodyStructure,
        name = equipment!.displayName,
        parent = parentNode;

  BodyStructure getBodyStructure() => bodyStructure;

  EquipmentFacade? getEquipment() => equipment;

  String getNodeType() => nodeType;

  EquipNode? getParent() => parent;

  EquipSlot? getSlot() => slot;

  String? getIdPath() => idPath;

  void setIdPath(String newIdPath) {
    idPath = newIdPath;
  }

  /// Returns the key to be used for sorting EquipNodes.
  String getSortKey() {
    StringBuffer sortKey = StringBuffer();
    if (parent != null) {
      sortKey.write(parent!.getSortKey());
    }
    switch (nodeType) {
      case nodeTypeBodySlot:
        sortKey.write(_order ?? '');
        break;
      case nodeTypePhantomSlot:
        sortKey.write('|');
        sortKey.write(slot?.slotName ?? '');
        break;
      case nodeTypeEquipment:
        sortKey.write('|');
        String? objKey = equipment?.sortKey;
        objKey ??= equipment?.displayName ?? '';
        sortKey.write(objKey);
        break;
    }
    return sortKey.toString();
  }

  @override
  String toString() => name;

  @override
  int compareTo(EquipNode other) {
    String orderThis = _getOrder(this);
    String orderOther = _getOrder(other);
    if (orderThis != orderOther) {
      return orderThis.compareTo(orderOther);
    }
    if (idPath != null && other.idPath != null) {
      return idPath!.compareTo(other.idPath!);
    }
    return getSortKey().compareTo(other.getSortKey());
  }

  String _getOrder(EquipNode node) {
    if (node._order != null && node._order!.isNotEmpty) {
      return node._order!;
    }
    EquipNode? p = node.parent;
    if (p != null) {
      return _getOrder(p);
    }
    return '';
  }
}
