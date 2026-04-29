import 'package:p7t_cli/p7t_cli.dart';
import 'package:test/test.dart';

import 'fakes/fake_terminal_io.dart';

void main() {
  group('App', () {
    test('runs chat with injected dependencies', () async {
      final terminal = FakeTerminalIO(['test input']);
      final app = App(terminal: terminal, service: const ChatService());
      await app.run();

      expect(terminal.outputs, isNotEmpty);
      expect(terminal.outputs.first, 'what can I do for you');
      expect(terminal.outputs, contains('it will be done'));
    });

    test('creates default dependencies when none provided', () {
      final app = App();
      expect(app.terminal, isA<StdioTerminalIO>());
      expect(app.service, isA<ChatService>());
    });
  });
}
