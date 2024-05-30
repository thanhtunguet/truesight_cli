import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

class MergeArbCommand extends Command<void> {
  @override
  final name = 'merge_arb';
  @override
  final description =
      'Merge arb files from lib/l10n/partials folder into a single flat file by locale and put it into lib/l10n/generated folder.';

  @override
  void run() async {
    final partialsDir = Directory('lib/l10n/partials');
    final generatedDir = Directory('lib/l10n/generated');

    if (!partialsDir.existsSync()) {
      print('Error: Partial directory does not exist.');
      return;
    }

    if (!generatedDir.existsSync()) {
      generatedDir.createSync(recursive: true);
    }

    final localeFiles = <String, Map<String, dynamic>>{};

    await for (var entityFile in partialsDir.list()) {
      if (entityFile is File && entityFile.path.endsWith('.arb')) {
        final content = await entityFile.readAsString();
        final locale = entityFile.path.split('_').last.split('.').first;
        final arbContent = json.decode(content) as Map<String, dynamic>;

        if (!localeFiles.containsKey(locale)) {
          localeFiles[locale] = {};
        }

        localeFiles[locale]!.addAll(arbContent);
      }
    }

    localeFiles.forEach((locale, content) {
      final outputFile = File('${generatedDir.path}/intl_$locale.arb');
      outputFile.writeAsStringSync(json.encode(content));

      print('Merged arb files for $locale');
    });

    print('Merge operation completed.');
  }
}
