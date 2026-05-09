import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pcgen/src/gui2/pc_gen_frame.dart';
import 'package:flutter_pcgen/src/gui2/startup/data_manager.dart';
import 'package:flutter_pcgen/src/gui2/startup/data_download_screen.dart';
import 'package:flutter_pcgen/src/gui3/preloader/pc_gen_preloader.dart';
import 'package:flutter_pcgen/src/gui3/preloader/pc_gen_preloader_controller.dart';
import 'package:flutter_pcgen/src/gui2/ui_context.dart';
import 'package:flutter_pcgen/src/gui2/ui_property_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_system_loader.dart';

class PCGenApp extends StatelessWidget {
  const PCGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UIContext()),
        ChangeNotifierProvider(create: (_) => UIPropertyContext.instance),
        ChangeNotifierProvider(create: (_) => PCGenPreloaderController()),
      ],
      child: Consumer<UIPropertyContext>(
        builder: (ctx, prefs, _) => MaterialApp(
          title: 'PCGen',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(prefs),
          home: const _PCGenRoot(),
        ),
      ),
    );
  }

  ThemeData _buildTheme(UIPropertyContext prefs) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }
}

/// Root widget: shows the preloader until initialisation completes,
/// then switches to the main PCGen frame.
class _PCGenRoot extends StatefulWidget {
  const _PCGenRoot();

  @override
  State<_PCGenRoot> createState() => _PCGenRootState();
}

class _PCGenRootState extends State<_PCGenRoot> {
  bool _ready = false;
  bool _needsDownload = false;

  final _dataMgr = DataManager();

  @override
  void initState() {
    super.initState();
    _checkData();
  }

  Future<void> _checkData() async {
    // Only mobile platforms need the download gate.
    if (Platform.isAndroid || Platform.isIOS) {
      final ready = await _dataMgr.isDataReady();
      if (!ready) {
        if (mounted) setState(() => _needsDownload = true);
        return;
      }
      await _dataMgr.configureDataRoot();
    }
    _initialise();
  }

  Future<void> _initialise() async {
    final controller = context.read<PCGenPreloaderController>();

    await LstSystemLoader().loadSystemResources(
      onProgress: (fraction, message) {
        controller.setProgress(fraction * 0.9, message);
      },
    );

    controller.setProgress(0.95, 'Starting GUI...');
    controller.complete();
    if (mounted) setState(() { _ready = true; _needsDownload = false; });
  }

  @override
  Widget build(BuildContext context) {
    // Show download screen on mobile when data files are absent.
    if (_needsDownload) {
      return DataDownloadScreen(
        onComplete: () {
          setState(() => _needsDownload = false);
          _initialise();
        },
      );
    }

    if (!_ready) {
      return PCGenPreloader(
        controller: context.read<PCGenPreloaderController>(),
      );
    }
    return PCGenFrame(context.read<UIContext>());
  }
}
