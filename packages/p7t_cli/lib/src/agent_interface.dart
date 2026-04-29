import 'message.dart';

/// Abstract interface for an agent that can reply to a conversation.
abstract class AgentInterface {
  const AgentInterface();

  /// Generates a reply based on the provided [context].
  ///
  /// The [context] contains the full conversation history up to this
  /// point.  Implementations should not mutate the list.
  Future<Message> ask(List<Message> context);
}

/// A mock implementation of [AgentInterface] for testing or local
/// development.
///
/// Always replies with the fixed message "it will be done" after a
/// short artificial delay.
final class AgentInterfaceMock implements AgentInterface {
  const AgentInterfaceMock();

  /// Artificial delay before returning the mock reply.
  static const Duration _mockDelay = Duration(milliseconds: 500);

  @override
  Future<Message> ask(List<Message> context) => Future.delayed(
    _mockDelay,
    () => Message(
      sender: MessageSender.agent,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
      content: 'it will be done',
    ),
  );
}
