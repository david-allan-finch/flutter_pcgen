//
// Copyright 2007 (C) James Dempsey
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
// Translation of pcgen.gui2.dialog.DataInstaller

import 'package:flutter/material.dart';

/// Dialog/tool for installing PCGen data sets from network or files.
class DataInstaller extends StatefulWidget {
  const DataInstaller({super.key});

  @override
  State<DataInstaller> createState() => _DataInstallerState();
}

class _DataInstallerState extends State<DataInstaller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Install Data')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, size: 64),
            SizedBox(height: 16),
            Text('Data installation interface'),
          ],
        ),
      ),
    );
  }
}
