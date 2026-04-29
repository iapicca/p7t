import 'message.dart';

/// Abstract interface for terminal UI interactions.
///
/// [Workflow] uses a [TuiInterface] to display messages, signal busy
/// state, and receive user input.  This abstraction keeps the workflow
/// agnostic of the concrete TUI framework.
abstract class TuiInterface {
  const TuiInterface();

  /// A stream of lines submitted by the user.
  Stream<String> get userInput;

  /// Displays [message] in the terminal UI.
  void displayMessage(Message message);

  /// Sets the busy indicator visibility.
  void setBusy(bool busy);

  /// Initialises the terminal UI (e.g. enters alternate screen).
  Future<void> init();

  /// Releases the terminal UI and restores normal terminal state.
  Future<void> dispose();
}
