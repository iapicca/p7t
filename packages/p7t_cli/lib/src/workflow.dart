import 'dart:async' show StreamSubscription;
import 'package:value_notifier/value_notifier.dart';

import 'agent_interface.dart';
import 'message.dart';
import 'terminal_interface.dart';

final class Workflow {
  final TerminalInterface terminal;
  final AgentInterface agent;

  Workflow({required this.agent, required this.terminal});

  late final ValueNotifier<List<Message>> _context;
  late final ValueNotifier<bool> _busy;
  late final StreamSubscription _inputSubscription;

  void _listentInput(String input) {
    if (input.isEmpty) {
      return;
    }
    _context.value.add(
      Message(
        content: input,
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.user,
      ),
    );
  }

  Future<void> _askAgent(List<Message> context) async {
    _busy.value = true;
    final reply = await agent.ask(context);
    _context.value = [...context, reply];
  }

  void _reply(String message) {
    _busy.value = false;
    terminal.write(message);
  }

  void _contextListener() async {
    final context = _context.value;
    switch (context.last.sender) {
      case MessageSender.user:
        await _askAgent(context);
        return;
      case MessageSender.agent:
        _reply(context.last.content);
        return;
    }
  }

  void _greet() {
    final context = _context.value;
    _context.value = [
      ...context,
      Message(
        content: 'what can I do for you',
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.agent,
      ),
    ];
  }

  void _exit() {
    final context = _context.value;
    _context.value = [
      ...context,
      Message(
        content: 'user exited',
        timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
        sender: MessageSender.agent,
      ),
    ];
  }

  void init() {
    _busy = ValueNotifier(true);
    _context = ValueNotifier([])..addListener(_contextListener);
    _inputSubscription = terminal.input.listen(_listentInput);
    _greet();
  }

  void dispose() {
    _exit();
    _context.removeListener(_contextListener);
    _context.dispose();
    _busy.dispose();
    _inputSubscription.cancel();
  }
}
