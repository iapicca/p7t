import 'dart:async' show StreamSubscription;

import 'agent_interface.dart';
import 'message.dart';
import 'tui_interface.dart';
import 'wellknown_messages.dart';

/// Orchestrates the chat loop between a [TuiInterface] and an
/// [AgentInterface].
///
/// The workflow maintains a conversation [_context] (a list of [Message]s)
/// and drives the state machine:
///
/// 1. On [init], a greeting is displayed via the TUI.
/// 2. Every user message triggers [_askAgent].
/// 3. When the agent replies, the reply is displayed.
/// 4. On [dispose], a system exit message is displayed and resources are
///    released.
///
/// The busy flag prevents overlapping agent requests.  If input arrives
/// while an agent request is already in flight, a polite "please wait"
/// system message is displayed instead.
final class Workflow {
  /// The TUI used to display messages and read user input.
  final TuiInterface tui;

  /// The agent that generates replies based on the conversation context.
  final AgentInterface agent;

  /// Creates a workflow that connects [agent] and [tui].
  ///
  /// [init] must be called before the workflow begins processing.
  Workflow({required this.agent, required this.tui});

  /// The ordered list of messages that make up the current conversation.
  List<Message> _context = [];

  /// Whether an agent request is currently in flight.
  bool _busy = false;

  /// Subscription to the TUI input stream.
  StreamSubscription<String>? _inputSubscription;

  /// Handles a line of user [input] from the TUI.
  ///
  /// Empty or whitespace-only input is ignored.  Otherwise a new user
  /// [Message] is appended to [_context] and the agent is asked for a
  /// reply.
  void _listenInput(String input) {
    if (input.trim().isEmpty) {
      return;
    }
    final message = Message(
      content: input,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
      sender: MessageSender.user,
    );
    _context = [..._context, message];
    tui.displayMessage(message);
    _askAgent();
  }

  /// Asks the [agent] for a reply based on the current [_context].
  ///
  /// If [_busy] is already `true`, a "please wait" system message is
  /// displayed immediately without calling the agent.  Otherwise the
  /// agent is consulted and [_busy] is set to `true` for the duration
  /// of the request.
  Future<void> _askAgent() async {
    if (_busy) {
      final reply = Message(
        content: WellknownMessages.wait,
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.system,
      );
      _context = [..._context, reply];
      tui.displayMessage(reply);
      return;
    }
    _busy = true;
    tui.setBusy(true);
    try {
      final reply = await agent.ask(_context);
      _context = [..._context, reply];
      tui.displayMessage(reply);
    } finally {
      _busy = false;
      tui.setBusy(false);
    }
  }

  /// Displays the greeting message via the TUI.
  void _greet() {
    final message = Message(
      content: WellknownMessages.greet,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
      sender: MessageSender.system,
    );
    _context = [..._context, message];
    tui.displayMessage(message);
  }

  /// Displays the exit message via the TUI.
  void _exit() {
    final message = Message(
      content: WellknownMessages.exit,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
      sender: MessageSender.system,
    );
    _context = [..._context, message];
    tui.displayMessage(message);
  }

  /// Starts the workflow.
  ///
  /// Initialises the TUI, subscribes to user input, and triggers the
  /// greeting.
  Future<void> init() async {
    await tui.init();
    _inputSubscription = tui.userInput.listen(_listenInput);
    _greet();
  }

  /// Tears down the workflow.
  ///
  /// Displays an exit message, cancels the input subscription, and
  /// disposes the TUI.
  Future<void> dispose() async {
    _exit();
    await _inputSubscription?.cancel();
    await tui.dispose();
  }
}
