import 'package:p7t_cli/p7t_cli.dart';
import 'package:test/test.dart';

void main() {
  group('StdioTerminalIO', () {
    test('delegates readLine to injected function', () {
      String? captured;
      final terminal = StdioTerminalIO(
        readLine: () => 'injected',
        writeLine: (text) => captured = text,
      );

      final result = terminal.readLine();
      expect(result, 'injected');
    });

    test('delegates writeLine to injected function', () {
      final buffer = <String>[];
      final terminal = StdioTerminalIO(
        readLine: () => null,
        writeLine: buffer.add,
      );

      terminal.writeLine('hello');
      expect(buffer, ['hello']);
    });

    test('defaults to non-null functions when no overrides given', () {
      final terminal = StdioTerminalIO();
      // Verify the object was created without exceptions.
      expect(terminal, isA<StdioTerminalIO>());
    });
  });
}
