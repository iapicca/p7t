import 'dart:async' show StreamSubscription;

import 'package:value_notifier/value_notifier.dart';

import 'agent_interface.dart';
import 'message.dart';
import 'terminal_interface.dart';
import 'wellknown_messages.dart';

/// Orchestrates the chat loop between a [TerminalInterface] and an
/// [AgentInterface].
///
/// The workflow maintains a conversation [context] (a list of [Message]s)
/// and drives the state machine:
///
/// 1. On [init], a greeting is appended to the context.
/// 2. Every user message appended to the context triggers [_askAgent].
/// 3. When the agent replies, the reply is appended and [_reply] prints it.
/// 4. On [dispose], a system exit message is appended and resources are
///    released.
///
/// The busy flag prevents overlapping agent requests.  If input arrives
/// while an agent request is already in flight, a polite "please wait"
/// system message is inserted instead.
final class Workflow {
  /// The terminal used to read user input and write output.
  final TerminalInterface terminal;

  /// The agent that generates replies based on the conversation context.
  final AgentInterface agent;

  /// Creates a workflow that connects [agent] and [terminal].
  ///
  /// [init] must be called before the workflow begins processing.
  Workflow({required this.agent, required this.terminal});

  /// The ordered list of messages that make up the current conversation.
  late final ValueNotifier<List<Message>> _context;

  /// Whether an agent request is currently in flight.
  late final ValueNotifier<bool> _busy;

  /// Subscription to the terminal input stream.
  late final StreamSubscription<String> _inputSubscription;

  /// Handles a line of user [input] from the terminal.
  ///
  /// Empty or whitespace-only input is ignored.  Otherwise a new user
  /// [Message] is appended to [_context].
  void _listenInput(String input) {
    if (input.trim().isEmpty) {
      return;
    }
    final context = _context.value;
    _context.value = [
      ...context,
      Message(
        content: input,
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.user,
      ),
    ];
  }

  /// Asks the [agent] for a reply based on the current [context].
  ///
  /// If [_busy] is already `true`, a "please wait" system message is
  /// returned immediately without calling the agent.  Otherwise the
  /// agent is consulted and [_busy] is set to `true` for the duration
  /// of the request.
  ///
  /// The reply is appended to [_context] when it arrives.
  Future<void> _askAgent(List<Message> context) async {
    late final Message reply;
    if (_busy.value) {
      reply = Message(
        content: '...please wait',
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.system,
      );
    } else {
      _busy.value = true;
      reply = await agent.ask(context);
    }
    _context.value = [...context, reply];
  }

  /// Prints the agent's [message] to the terminal and clears the busy
  /// flag.
  void _reply(String message) {
    _busy.value = false;
    terminal.write(message);
  }

  /// Called whenever [_context] changes.
  ///
  /// Routes the last message in the context to the appropriate handler:
  /// * [MessageSender.user] → [_askAgent]
  /// * [MessageSender.agent] → [_reply]
  /// * [MessageSender.system] → [terminal.write]
  void _contextListener() async {
    final context = _context.value;
    switch (context.last.sender) {
      case MessageSender.user:
        await _askAgent(context);
        return;
      case MessageSender.agent:
        _reply(context.last.content);
        return;
      default:
        terminal.write(context.last.content);
        return;
    }
  }

  /// Appends a greeting system message to the context.
  void _greet() {
    final context = _context.value;
    _context.value = [
      ...context,
      Message(
        content: WellknownMessages.greet,
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.system,
      ),
    ];
  }

  /// Appends a system exit message to the context.
  void _exit() {
    final context = _context.value;
    _context.value = [
      ...context,
      Message(
        content: WellknownMessages.exit,
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.system,
      ),
    ];
  }

  /// Starts the workflow.
  ///
  /// Initializes internal state, subscribes to terminal input, and
  /// triggers the greeting.
  Future<void> init() async {
    _busy = ValueNotifier(false);
    _context = ValueNotifier([])..addListener(_contextListener);
    _inputSubscription = terminal.input.listen(_listenInput);
    _greet();
  }

  /// Tears down the workflow.
  ///
  /// Appends an exit message, removes listeners, disposes value
  /// notifiers, and cancels the input subscription.
  Future<void> dispose() async {
    _exit();
    _context
      ..removeListener(_contextListener)
      ..dispose();
    _busy.dispose();
    await _inputSubscription.cancel();
  }
}
