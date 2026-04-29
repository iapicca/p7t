import 'chat_service.dart';
import 'message.dart';
import 'terminal_io.dart';

/// Orchestrates the read-eval-print loop for the terminal chat.
class ChatRunner {
  /// The prompt shown to the user before each input.
  static const _prompt = 'what can I do for you';

  /// Interface for terminal I/O.
  final TerminalIO terminal;

  /// Service that generates responses.
  final ChatService service;

  /// Creates a new [ChatRunner] with the given dependencies.
  const ChatRunner({
    required this.terminal,
    required this.service,
  });

  /// Runs the chat loop until EOF is reached.
  Future<void> run() async {
    while (true) {
      terminal.writeLine(_prompt);
      final input = terminal.readLine();
      if (input == null) break;

      final response = await service.processInput(input);
      terminal.writeLine(response.content);
    }
  }
}
