import 'dart:convert' show utf8, LineSplitter;
import 'dart:io' show stdin, stdout;

/// Abstract interface for terminal I/O.
abstract class TerminalInterface {
  const TerminalInterface();

  /// A stream of lines read from the terminal.
  Stream<String> get input;

  /// Writes [text] to the terminal output.
  void write(String text);

  /// Creates a terminal interface backed by standard input and output.
  const factory TerminalInterface.stdio() = _TerminalInterfaceStdio;
}

/// A [TerminalInterface] implementation that uses [stdin] and [stdout].
final class _TerminalInterfaceStdio implements TerminalInterface {
  const _TerminalInterfaceStdio();

  @override
  Stream<String> get input =>
      stdin.transform(utf8.decoder).transform(const LineSplitter());

  @override
  void write(String text) => stdout.writeln(text);
}
