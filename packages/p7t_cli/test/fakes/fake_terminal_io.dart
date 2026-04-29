import 'package:p7t_cli/p7t_cli.dart';

/// Fake [TerminalIO] that replays canned inputs and records outputs.
class FakeTerminalIO implements TerminalIO {
  /// Canned inputs to return from [readLine] in order.
  final List<String?> inputs;

  /// Lines written via [writeLine].
  final List<String> outputs = [];

  /// Current index into [inputs].
  int _index = 0;

  /// Creates a fake terminal with the given [inputs].
  FakeTerminalIO(this.inputs);

  @override
  String? readLine() {
    if (_index >= inputs.length) return null;
    return inputs[_index++];
  }

  @override
  void writeLine(String text) => outputs.add(text);
}
