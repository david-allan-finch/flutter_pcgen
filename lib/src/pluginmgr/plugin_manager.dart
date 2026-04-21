//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.pluginmgr.PluginManager

import 'package:flutter_pcgen/src/pluginmgr/message_handler_manager.dart';
import 'package:flutter_pcgen/src/pluginmgr/p_c_gen_message.dart';
import 'package:flutter_pcgen/src/pluginmgr/p_c_gen_message_handler.dart';

/// Singleton plugin manager that dispatches messages to registered plugins.
final class PluginManager {
  static PluginManager? _instance;

  final MessageHandlerManager _msgHandlerMgr = MessageHandlerManager();

  PluginManager._();

  static PluginManager getInstance() {
    _instance ??= PluginManager._();
    return _instance!;
  }

  void addMember(PCGenMessageHandler handler) =>
      _msgHandlerMgr.addMember(handler);

  void removeMember(PCGenMessageHandler handler) =>
      _msgHandlerMgr.removeMember(handler);

  void sendMessage(PCGenMessage msg) => _msgHandlerMgr.handleMessage(msg);
}
