import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

class ExtractKeysCommand extends Command<void> {
  @override
  final name = 'extract_keys';
  @override
  final description =
      'Scan lib directory, extract callee of AppLocalizations keys, and write them into partial .arb files in lib/l10n/partials.';

  ExtractKeysCommand() {
    argParser.addMultiOption(
      'locales',
      abbr: 'l',
      help: 'Supported locales. Default to vi and en.',
      defaultsTo: ['vi', 'en'],
    );
  }

  @override
  void run() async {
    final supportedLocales = argResults?['locales'] as List<String>;

    final libDir = Directory('lib');
    final partialsDir = Directory('lib/l10n/partials');

    if (!libDir.existsSync()) {
      print('Error: lib directory does not exist.');
      return;
    }

    if (!partialsDir.existsSync()) {
      partialsDir.createSync(recursive: true);
    }

    // Step 1: Detect all entity names
    final entityNames = _getEntityNames(partialsDir);
    print('Detected entity names: $entityNames');

    final keysByEntity = <String, Set<String>>{};

    // Step 2: Scan Dart files in lib directory for keys
    await for (var entityFile in libDir.list(recursive: true)) {
      if (entityFile is File && entityFile.path.endsWith('.dart')) {
        final content = await entityFile.readAsString();
        final matches = RegExp(r'App(Localizations|Locale)\.of\(context\)\.(\w+)').allMatches(content);

        for (var match in matches) {
          final key = match.group(2);
          if (key != null) {
            // Step 3: Match the key with entity names
            final matchedEntity =
                entityNames.firstWhere((entity) => key.startsWith(entity), orElse: () => 'miscellaneous');

            keysByEntity.putIfAbsent(matchedEntity, () => {}).add(key);
          }
        }
      }
    }

    // Step 4: Write keys to corresponding .arb files
    for (var entity in keysByEntity.keys) {
      for (var locale in supportedLocales) {
        final arbFile = File(path.join(partialsDir.path, '${entity}_$locale.arb'));
        final existingKeys = _getExistingKeys(arbFile);

        final combinedKeys = existingKeys.union(keysByEntity[entity]!);
        final outputContent = _generateArbContent(combinedKeys);

        arbFile.writeAsStringSync(outputContent);
        print('Keys extracted and saved to ${arbFile.path}');
      }
    }

    print('Extraction operation completed.');
  }

  List<String> _getEntityNames(Directory partialsDir) {
    final entityNames = <String>{};

    for (var file in partialsDir.listSync()) {
      if (file is File && file.path.endsWith('.arb')) {
        final filename = path.basenameWithoutExtension(file.path);
        final entityName = filename.replaceAll(RegExp(r'_[a-z]{2}$'), '');
        entityNames.add(entityName);
      }
    }

    return entityNames.toList()..sort();
  }

  Set<String> _getExistingKeys(File arbFile) {
    if (!arbFile.existsSync()) {
      return {};
    }

    final content = arbFile.readAsStringSync();
    final decoded = json.decode(content) as Map<String, dynamic>;

    return decoded.keys.toSet();
  }

  String _generateArbContent(Set<String> keys) {
    final Map<String, String> arbContent = {for (var key in keys) key: ''};
    return const JsonEncoder.withIndent('  ').convert(arbContent);
  }
}
