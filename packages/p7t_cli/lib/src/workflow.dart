import 'dart:async' show StreamSubscription;

import 'package:p7t_cli/src/logic/context_provider.dart';
import 'package:value_notifier/value_notifier.dart';

import 'domain/agent_interface.dart';
import 'domain/message.dart';
import 'domain/terminal_interface.dart';
import 'domain/types.dart';
import 'wellknown_messages.dart';

final class Workflow {
  final TerminalInterface terminal;

  final AgentInterface agent;

  Workflow({required this.agent, required this.terminal});

  late final ContextManager _context;

  late final StreamSubscription<String> _inputSubscription;

  void _listenInput(String input) {
    if (input.trim().isEmpty) {
      return;
    }
    _context.add(
      Message(
        content: input,
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.user,
      ),
    );
  }

  /// Asks the [agent] for a reply based on the current [context].
  ///
  /// If [_busy] is already `true`, a "please wait" system message is
  /// returned immediately without calling the agent.  Otherwise the
  /// agent is consulted and [_busy] is set to `true` for the duration
  /// of the request.
  ///
  /// The reply is appended to [_context] when it arrives.
  Future<void> _askAgent(ContextManager context) async {

terminal.status

      terminal.status.busy = true;
      message = await agent.ask(context);
    }
    _context.value = [...context, message];
  }

  void _reply(String message) {
    terminal.status.busy = false;
    terminal.write(message);
  }

  /// Called whenever [_context] changes.
  ///
  /// Routes the last message in the context to the appropriate handler:
  /// * [MessageSender.user] → [_askAgent]
  /// * [MessageSender.agent] → [_reply]
  /// * [MessageSender.system] → [terminal.write]
  void _contextListener() async {
    switch (_context.last.sender) {
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
