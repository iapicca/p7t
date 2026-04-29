import 'chat_runner.dart';
import 'chat_service.dart';
import 'terminal_io.dart';

/// Composition root that wires the application together.
class App {
  /// Terminal I/O implementation. Defaults to [StdioTerminalIO].
  final TerminalIO terminal;

  /// Service that generates responses. Defaults to [ChatService].
  final ChatService service;

  /// Creates a new [App].
  /// Dependencies may be injected for testing.
  App({
    TerminalIO? terminal,
    ChatService? service,
  })  : terminal = terminal ?? StdioTerminalIO(),
        service = service ?? const ChatService();

  /// Starts the terminal chat application.
  Future<void> run() async {
    final runner = ChatRunner(terminal: terminal, service: service);
    await runner.run();
  }
}
