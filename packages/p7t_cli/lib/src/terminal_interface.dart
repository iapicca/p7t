import 'dart:convert' show utf8, LineSplitter;
import 'dart:io' show stdin, stdout;

abstract class TerminalInterface {
  const TerminalInterface();
  Stream<String> get input;
  void write(String text);

  const factory TerminalInterface.stdio() = _TerminalInterfaceStdio;
}

final class _TerminalInterfaceStdio implements TerminalInterface {
  const _TerminalInterfaceStdio();
  @override
  Stream<String> get input =>
      stdin.transform(utf8.decoder).transform(const LineSplitter());

  @override
  void write(String text) => stdout.writeln(text);
}
