import 'dart:async';

import 'package:p7t_cli/p7t_cli.dart';
import 'package:p7t_cli/src/domain/message.dart';
import 'package:p7t_cli/src/wellknown_messages.dart';
import 'package:test/test.dart';

/// A fake TUI that feeds input via a synchronous broadcast stream
/// and records everything displayed to it.
class _FakeTui implements TuiInterface {
  final _controller = StreamController<String>.broadcast(sync: true);
  final List<Message> displayedMessages = [];
  final List<bool> busyStates = [];

  @override
  Stream<String> get userInput => _controller.stream;

  @override
  void displayMessage(Message message) => displayedMessages.add(message);

  @override
  void setBusy(bool busy) => busyStates.add(busy);

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  void send(String text) {
    if (!_controller.isClosed) {
      _controller.add(text);
    }
  }
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
    late _FakeTui tui;
    late _FakeAgent agent;
    late Workflow workflow;

    setUp(() async {
      tui = _FakeTui();
      agent = _FakeAgent();
      workflow = Workflow(agent: agent, tui: tui);
      await workflow.init();
    });

    tearDown(() async {
      await workflow.dispose();
    });

    test('init appends greeting and displays it', () {
      expect(tui.displayedMessages.length, 1);
      expect(tui.displayedMessages.first.content, WellknownMessages.greet);
      expect(tui.displayedMessages.first.sender, MessageSender.system);
    });

    test('user input triggers agent ask', () async {
      tui.send('hello');
      await Future(() {});
      expect(agent.pendingCount, 1);
    });

    test('agent reply is displayed', () async {
      tui.send('hello');
      await Future(() {});

      agent.completeNext(
        const Message(
          content: 'hi there',
          timestamp: 1,
          sender: MessageSender.agent,
        ),
      );
      await Future(() {});

      expect(tui.displayedMessages.length, 3); // greet + user + agent
      expect(tui.displayedMessages.last.content, 'hi there');
      expect(tui.displayedMessages.last.sender, MessageSender.agent);
    });

    test('empty input is ignored', () async {
      tui.send('   ');
      await Future(() {});
      expect(agent.pendingCount, 0);
    });

    test('does not crash when input arrives while busy', () async {
      tui.send('msg1');
      await Future(() {});
      tui.send('msg2');
      await Future(() {});
      expect(agent.pendingCount, 1);
    });

    test('reply clears busy flag', () async {
      tui.send('hello');
      await Future(() {});

      agent.completeNext(
        const Message(
          content: 'reply',
          timestamp: 1,
          sender: MessageSender.agent,
        ),
      );
      await Future(() {});

      tui.send('hello2');
      await Future(() {});
      expect(agent.pendingCount, 1);
    });

    test('busy states are set correctly', () async {
      tui.send('hello');
      await Future(() {});
      expect(tui.busyStates, [true]);

      agent.completeNext(
        const Message(
          content: 'reply',
          timestamp: 1,
          sender: MessageSender.agent,
        ),
      );
      await Future(() {});
      expect(tui.busyStates, [true, false]);
    });

    test('dispose appends exit message and displays it', () async {
      await workflow.dispose();
      final contents = tui.displayedMessages.map((m) => m.content).toList();
      expect(contents, contains(WellknownMessages.exit));
    });

    test('dispose cancels input subscription', () async {
      await workflow.dispose();
      tui.send('after dispose');
      await Future(() {});
      expect(agent.pendingCount, 0);
    });

    test('system messages do not trigger agent', () {
      expect(agent.pendingCount, 0);
    });
  });
}
