import 'dart:async';

import 'package:p7t_cli/p7t_cli.dart';
import 'package:test/test.dart';

void main() {
  group('TerminalInterface', () {
    test('stdio factory creates an instance', () {
      const terminal = TerminalInterface.stdio();
      expect(terminal, isA<TerminalInterface>());
    });
  });

  group('_TerminalInterfaceStdio', () {
    test('input and write are exposed', () {
      // The real stdio implementation binds to stdin/stdout.
      // We verify the contract by ensuring the factory returns a
      // concrete type with the expected members.
      const terminal = TerminalInterface.stdio();
      expect(terminal.input, isA<Stream<String>>());
      expect(() => terminal.write('test'), returnsNormally);
    });
  });
}
