import 'package:p7t_cli/p7t_cli.dart';
import 'package:test/test.dart';

import 'fakes/fake_terminal_io.dart';

void main() {
  group('ChatRunner', () {
    const service = ChatService();

    test('writes prompt and response for one input', () async {
      final terminal = FakeTerminalIO(['hello']);
      final runner = ChatRunner(terminal: terminal, service: service);
      await runner.run();

      // Prompt, response, then final prompt before EOF.
      expect(terminal.outputs.length, 3);
      expect(terminal.outputs[0], 'what can I do for you');
      expect(terminal.outputs[1], 'it will be done');
      expect(terminal.outputs[2], 'what can I do for you');
    });

    test('exits on EOF after printing one prompt', () async {
      final terminal = FakeTerminalIO([]);
      final runner = ChatRunner(terminal: terminal, service: service);
      await runner.run();

      expect(terminal.outputs, ['what can I do for you']);
    });

    test('processes multiple inputs until EOF', () async {
      final terminal = FakeTerminalIO(['a', 'b', null]);
      final runner = ChatRunner(terminal: terminal, service: service);
      await runner.run();

      // Prompt/response pairs plus trailing prompt before null.
      expect(terminal.outputs.length, 5);
      expect(terminal.outputs[0], 'what can I do for you');
      expect(terminal.outputs[1], 'it will be done');
      expect(terminal.outputs[2], 'what can I do for you');
      expect(terminal.outputs[3], 'it will be done');
      expect(terminal.outputs[4], 'what can I do for you');
    });

    test('passes correct input to service', () async {
      final terminal = FakeTerminalIO(['custom input']);
      final runner = ChatRunner(terminal: terminal, service: service);
      await runner.run();

      expect(terminal.outputs, contains('it will be done'));
    });
  });
}
