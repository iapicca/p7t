import 'dart:io';

/// Abstract interface for terminal input/output operations.
abstract class TerminalIO {
  /// Reads one line from the terminal. Returns null on EOF.
  String? readLine();

  /// Writes [text] followed by a newline to the terminal.
  void writeLine(String text);
}

/// [TerminalIO] implementation backed by stdin and stdout.
class StdioTerminalIO implements TerminalIO {
  /// Function used to read a line. Defaults to [stdin.readLineSync].
  final String? Function() _readLine;

  /// Function used to write a line. Defaults to [stdout.writeln].
  final void Function(String) _writeLine;

  /// Creates a new [StdioTerminalIO].
  /// [readLine] and [writeLine] may be injected for testing.
  StdioTerminalIO({
    String? Function()? readLine,
    void Function(String)? writeLine,
  })  : _readLine = readLine ?? stdin.readLineSync,
        _writeLine = writeLine ?? stdout.writeln;

  @override
  String? readLine() => _readLine();

  @override
  void writeLine(String text) => _writeLine(text);
}
