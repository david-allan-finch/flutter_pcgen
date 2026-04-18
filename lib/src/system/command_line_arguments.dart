// Translation of pcgen.system.CommandLineArguments

/// Parses and holds the command-line arguments passed to PCGen.
class CommandLineArguments {
  String? settingsDir;
  String? characterFile;
  String? exportSheet;
  String? outputFile;
  bool startInCLI = false;

  CommandLineArguments(List<String> args) {
    _parse(args);
  }

  void _parse(List<String> args) {
    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--settingsdir':
          if (i + 1 < args.length) settingsDir = args[++i];
        case '--character':
          if (i + 1 < args.length) characterFile = args[++i];
        case '--exportsheet':
          if (i + 1 < args.length) exportSheet = args[++i];
        case '--outputfile':
          if (i + 1 < args.length) outputFile = args[++i];
        case '--headless':
          startInCLI = true;
      }
    }
  }
}
