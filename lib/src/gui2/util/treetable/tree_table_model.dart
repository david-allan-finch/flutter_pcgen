//
//
// Copyright (c) 1998 Sun Microsystems, Inc. All Rights Reserved.
//
// This software is the confidential and proprietary information of Sun
// Microsystems, Inc. ("Confidential Information").  You shall not
// disclose such Confidential Information and shall use it only in
// accordance with the terms of the license agreement you entered into
// with Sun.
//
// SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
// SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE, OR NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR ANY DAMAGES
// SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
// THIS SOFTWARE OR ITS DERIVATIVES.
//
// Translation of pcgen.gui2.util.treetable.TreeTableModel

import 'package:flutter_pcgen/src/gui2/util/treetable/tree_table_node.dart';

/// Model for a tree-table (combined tree and table view).
abstract class TreeTableModel {
  TreeTableNode get root;
  int get columnCount;
  String getColumnName(int column);
  Type getColumnClass(int column);
  bool isCellEditable(TreeTableNode node, int column);
  dynamic getValueAt(TreeTableNode node, int column);
  void setValueAt(dynamic value, TreeTableNode node, int column);
  void addTreeModelListener(dynamic listener);
  void removeTreeModelListener(dynamic listener);
}
