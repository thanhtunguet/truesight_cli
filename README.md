# truesight_cli

A CLI tool for Flutter projects to manage localization keys and ensure they are correctly mapped to `.arb` files.

## Installation

To install the `truesight_cli` globally from your GitHub repository:

```bash
dart pub global activate --source git https://github.com/yourusername/truesight_cli.git
```

Make sure to replace `yourusername` with your actual GitHub username.

## Commands

### `validate_models`

Scans the `lib/models` and `lib/filters` directories to ensure all fields are added to the `fields` getter in model files and checks for duplications.

#### Usage

```bash
truesight_cli validate_models
```

### `merge_arb`

Merges `.arb` files from the `lib/l10n/partials` folder into a single flat file for each locale and places the generated files into the `lib/l10n/generated` folder.

#### Usage

```bash
truesight_cli merge_arb
```

### `extract_keys`

Scans the `lib` directory, extracts the callee of `AppLocalizations` or `AppLocale` keys, and writes them into partial `.arb` files in `lib/l10n/partials`. It also organizes the keys into corresponding files based on detected entity names. If the entity name does not exist, a new file is created.

#### Usage

```bash
truesight_cli extract_keys -l <locales>
```

#### Arguments

- `-l`, `--locales`: Supported locales. Default to `vi` and `en`.

### Examples

#### Extract keys with default locales (vi, en)

```bash
truesight_cli extract_keys
```

#### Extract keys with specific locales

```bash
truesight_cli extract_keys -l es,fr,de
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License.
