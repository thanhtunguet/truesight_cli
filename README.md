# truesight_cli

`truesight_cli` is a command-line tool for managing and validating Dart models. It provides commands to greet users and validate model files to ensure all fields are included in the `fields` getter without any duplication.

## Installation

To install the `truesight_cli`, you need to have Dart installed on your machine. You can then activate the CLI globally using the following command:

```sh
dart pub global activate --source git https://github.com/thanhtunguet/truesight_cli.git
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
