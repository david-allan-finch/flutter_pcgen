import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gui2/pc_gen_frame.dart';
import 'gui3/preloader/pc_gen_preloader.dart';
import 'gui3/preloader/pc_gen_preloader_controller.dart';
import 'gui2/ui_context.dart';
import 'gui2/ui_property_context.dart';

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

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    final controller = context.read<PCGenPreloaderController>();

    controller.setProgress(0.1, 'Loading configuration...');
    await Future.delayed(const Duration(milliseconds: 100));

    controller.setProgress(0.3, 'Loading game data...');
    await Future.delayed(const Duration(milliseconds: 100));

    controller.setProgress(0.6, 'Initialising systems...');
    await Future.delayed(const Duration(milliseconds: 100));

    controller.setProgress(0.9, 'Starting GUI...');
    await Future.delayed(const Duration(milliseconds: 100));

    controller.complete();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return PCGenPreloader(
        controller: context.read<PCGenPreloaderController>(),
      );
    }
    return PCGenFrame(context.read<UIContext>());
  }
}
