import 'package:args/command_runner.dart';

class GreetCommand extends Command<void> {
  @override
  final name = 'greet';

  @override
  final description = 'Greet someone.';

  GreetCommand() {
    argParser.addOption('name', abbr: 'n', help: 'Name of the person to greet.');
  }

  @override
  void run() {
    final name = argResults?['name'] ?? 'world';
    print('Hello, $name!');
  }
}
