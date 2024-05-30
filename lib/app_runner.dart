import 'package:args/command_runner.dart';
import 'package:truesight_cli/greet_command.dart';
import 'package:truesight_cli/validate_models_command.dart';

class AppRunner extends CommandRunner<void> {
  AppRunner() : super('truesight_cli', 'A sample CLI package') {
    addCommand(GreetCommand());
    addCommand(ValidateModelsCommand());
  }
}
