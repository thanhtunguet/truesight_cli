# truesight_cli

`truesight_cli` is a command-line tool for managing and validating Dart models. It provides commands to greet users and validate model files to ensure all fields are included in the `fields` getter without any duplication.

## Installation

To install the `truesight_cli`, you need to have Dart installed on your machine. You can then activate the CLI globally using the following command:

```sh
dart pub global activate --source git https://github.com/<your-username>/<your-repository>.git
```

Replace `<your-username>` with your GitHub username and `<your-repository>` with the name of your repository. For example:

```sh
dart pub global activate --source git https://github.com/johnDoe/truesight_cli.git
```

## Usage

Once installed, you can use the `truesight_cli` from anywhere in your terminal.

### Commands

#### 1. Greet Command

The `greet` command allows you to greet someone by their name.

Usage:
```sh
truesight_cli greet --name=<name>
```

Example:
```sh
truesight_cli greet --name=John
# Output: Hello, John!
```

If you don't provide a name, it defaults to "world".

Example:
```sh
truesight_cli greet
# Output: Hello, world!
```

#### 2. Validate Models Command

The `validate_models` command scans specified directories (defaulting to `lib/models` and `lib/filters`) to ensure that all fields in the model files are added to the `fields` getter and there are no duplicates.

Usage:
```sh
truesight_cli validate_models --folders=<folder1>,<folder2>,...
```

If no folders are specified, it defaults to scanning `lib/models` and `lib/filters`.

Example with custom folders:
```sh
truesight_cli validate_models --folders=lib/models,lib/filters,lib/extra
```

To use the default folders:
```sh
truesight_cli validate_models
# This will scan the lib/models and lib/filters directories.
```

This command will:
- Scan through the specified directories.
- Check each Dart file for declared fields.
- Ensure all declared fields are included in the `fields` getter.
- Ensure there are no duplicate fields in the `fields` getter.

### Help

For a complete list of commands and their usage, you can always use the `--help` option.

Global help:
```sh
truesight_cli --help
```

Help for a specific command:
```sh
truesight_cli help <command>
```

Example:
```sh
truesight_cli help validate_models
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue on GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### Updated Command Implementation

Here is the updated implementation for the `ValidateModelsCommand`:

```dart
import 'dart:io';
import 'package:args/command_runner.dart';

class ValidateModelsCommand extends Command<void> {
  @override
  final name = 'validate_models';
  @override
  final description = 'Validate that all fields in model files are included in the fields getter and ensure no duplicates.';

  ValidateModelsCommand() {
    argParser.addMultiOption(
      'folders',
      abbr: 'f',
      help: 'List of folders to scan. Defaults to "lib/models" and "lib/filters".',
      defaultsTo: ['lib/models', 'lib/filters'],
    );
  }

  @override
  void run() {
    final folders = argResults?['folders'] as List<String>;

    for (var dir in folders) {
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
    final fieldsPattern = RegExp(r'Json\w+ (\w+) =');
    final getterPattern = RegExp(r'List<JsonField> get fields => \[(.*?)\];', dotAll: true);

    final fields = <String>{};
    final declaredFields = <String>{};
    final getterMatch = getterPattern.firstMatch(content);

    if (getterMatch != null) {
      final getterContent = getterMatch.group(1)!;
      final getterFields = getterContent.split(',').map((f) => f.trim());

      declaredFields.addAll(getterFields);
    }

    for (final match in fieldsPattern.allMatches(content)) {
      fields.add(match.group(1)!);
    }

    final missingFields = fields.difference(declaredFields);
    final duplicateFields = declaredFields.difference(fields);

    if (missingFields.isNotEmpty) {
      print('File ${file.path} is missing fields in the fields getter: ${missingFields.join(', ')}');
    }

    if (duplicateFields.isNotEmpty) {
      print('File ${file.path} has duplicate fields in the fields getter: ${duplicateFields.join(', ')}');
    }

    if (missingFields.isEmpty && duplicateFields.isEmpty) {
      print('File ${file.path} is valid.');
    }
  }
}
```
