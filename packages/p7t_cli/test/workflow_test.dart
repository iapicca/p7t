import 'dart:async';

import 'package:p7t_cli/p7t_cli.dart';
import 'package:p7t_cli/src/message.dart';
import 'package:p7t_cli/src/wellknown_messages.dart';
import 'package:test/test.dart';

/// A fake terminal that feeds input via a synchronous broadcast stream
/// and records everything written to it.
class _FakeTerminal implements TerminalInterface {
  final _controller = StreamController<String>.broadcast(sync: true);
  final List<String> outputs = [];

  @override
  Stream<String> get input => _controller.stream;

  @override
  void write(String text) => outputs.add(text);

  void send(String text) => _controller.add(text);
}

/// A fake agent that exposes pending requests as [Completer]s so tests
/// can control when each reply is delivered.
class _FakeAgent implements AgentInterface {
  final _completers = <Completer<Message>>[];

  @override
  Future<Message> ask(List<Message> context) {
    final completer = Completer<Message>();
    _completers.add(completer);
    return completer.future;
  }

  void completeNext(Message message) {
    if (_completers.isEmpty) {
      throw StateError('No pending agent requests');
    }
    _completers.removeAt(0).complete(message);
  }

  int get pendingCount => _completers.length;
}

void main() {
  group('Workflow', () {
    late _FakeTerminal terminal;
    late _FakeAgent agent;
    late Workflow workflow;

    setUp(() async {
      terminal = _FakeTerminal();
      agent = _FakeAgent();
      workflow = Workflow(agent: agent, terminal: terminal);
      await workflow.init();
    });

    tearDown(() async {
      await workflow.dispose();
    });

    test('init appends greeting and writes it to terminal', () {
      expect(terminal.outputs, [WellknownMessages.greet]);
    });

    test('user input triggers agent ask', () async {
      terminal.send('hello');
      await Future(() {});
      expect(agent.pendingCount, 1);
    });

    test('agent reply is written to terminal', () async {
      terminal.outputs.clear();

      terminal.send('hello');
      await Future(() {});

      agent.completeNext(
        const Message(
          content: 'hi there',
          timestamp: 1,
          sender: MessageSender.agent,
        ),
      );
      await Future(() {});

      expect(terminal.outputs, ['hi there']);
    });

    test('empty input is ignored', () async {
      terminal.send('   ');
      await Future(() {});
      expect(agent.pendingCount, 0);
    });

    test('does not crash when input arrives while busy', () async {
      terminal.send('msg1');
      await Future(() {});
      terminal.send('msg2');
      await Future(() {});
      expect(agent.pendingCount, 1);
    });

    test('reply clears busy flag', () async {
      terminal.send('hello');
      await Future(() {});

      agent.completeNext(
        const Message(
          content: 'reply',
          timestamp: 1,
          sender: MessageSender.agent,
        ),
      );
      await Future(() {});

      terminal.send('hello2');
      await Future(() {});
      expect(agent.pendingCount, 1);
    });

    test('dispose appends exit message and writes it to terminal',
        () async {
      await workflow.dispose();
      expect(terminal.outputs, contains(WellknownMessages.exit));
    });

    test('dispose cancels input subscription', () async {
      await workflow.dispose();
      terminal.send('after dispose');
      await Future(() {});
      expect(agent.pendingCount, 0);
    });

    test('system messages do not trigger agent', () {
      expect(agent.pendingCount, 0);
    });
  });
}
