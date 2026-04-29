import 'message.dart';

abstract class AgentInterface {
  const AgentInterface();

  Future<Message> ask(List<Message> context);
}

final class AgentInterfaceMock implements AgentInterface {
  const AgentInterfaceMock();
  static const Duration _mockDelay = Duration(milliseconds: 500);
  @override
  Future<Message> ask(List<Message> context) => Future.delayed(
    _mockDelay,
    () => Message(
      sender: MessageSender.agent,
      timestamp: DateTime.now().toUtc().microsecondsSinceEpoch,
      content: 'it will be done',
    ),
  );
}
