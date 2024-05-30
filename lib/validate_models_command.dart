import 'dart:io';

import 'package:args/command_runner.dart';

class ValidateModelsCommand extends Command<void> {
  @override
  final name = 'validate_models';
  @override
  final description =
      'Validate that all fields in model files are included in the fields getter and ensure no duplicates.';

  ValidateModelsCommand() : super() {
    argParser.addMultiOption(
      'folders',
      abbr: 'f',
      help: 'List of folders to scan. Defaults to "lib/models".',
      defaultsTo: ['lib/models', 'lib/filters'],
    );
  }

  @override
  void run() {
    final directories = argResults?['folders'] as List<String>;

    for (var dir in directories) {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        print('Directory $dir does not exist.');
        continue;
      }

      for (var file in directory.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          validateFile(file);
        }
      }
    }
  }

  void validateFile(File file) {
    final content = file.readAsStringSync();
    final fieldsPattern = RegExp(r'Json[^ \n\r]+\s+([^ \n\r]+)\s+=');
    final getterPattern = RegExp(r'List<JsonField> get fields => \[(.*?)\];', dotAll: true);

    final fields = <String>{};
    final declaredFields = <String>{};
    final getterMatch = getterPattern.firstMatch(content);

    if (getterMatch != null) {
      final getterContent = getterMatch.group(1)!;
      final getterFields =
          getterContent.trim().split(RegExp(r',\s*')).map((f) => f.trim()).where((f) => f.isNotEmpty).toList();

      declaredFields.addAll(getterFields);
    }

    for (final match in fieldsPattern.allMatches(content)) {
      final matchedGroup = match.group(1)!;
      fields.add(matchedGroup);
    }

    final missingFields = fields.difference(declaredFields);
    // final duplicateFields = declaredFields.difference(fields);

    if (missingFields.isNotEmpty) {
      print('File ${file.path} is missing fields in the fields getter: ${missingFields.join(', ')}');
    }

    // if (duplicateFields.isNotEmpty) {
    //   print('File ${file.path} has duplicate fields in the fields getter: ${duplicateFields.join(', ')}');
    // }

    // if (missingFields.isEmpty && duplicateFields.isEmpty) {
    //   print('File ${file.path} is valid.');
    // }
  }
}
