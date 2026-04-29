import 'package:p7t_cli/src/agent_interface.dart';
import 'package:p7t_cli/src/message.dart';
import 'package:test/test.dart';

void main() {
  group('AgentInterfaceMock', () {
    test('returns a message with agent sender', () async {
      const mock = AgentInterfaceMock();
      final reply = await mock.ask([]);
      expect(reply.sender, MessageSender.agent);
    });

    test('returns fixed content', () async {
      const mock = AgentInterfaceMock();
      final reply = await mock.ask([]);
      expect(reply.content, 'it will be done');
    });

    test('returns a valid timestamp', () async {
      const mock = AgentInterfaceMock();
      final before = DateTime.now().toUtc().millisecondsSinceEpoch;
      final reply = await mock.ask([]);
      final after = DateTime.now().toUtc().millisecondsSinceEpoch;
      expect(reply.timestamp, greaterThanOrEqualTo(before));
      expect(reply.timestamp, lessThanOrEqualTo(after));
    });
  });
}
