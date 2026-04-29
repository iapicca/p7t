import 'message.dart';

/// Business logic that generates responses to user messages.
class ChatService {
  /// Delay before responding, in milliseconds.
  static const _responseDelayMs = 500;

  /// The fixed response text for any user input.
  static const _responseText = 'it will be done';

  /// Creates a new [ChatService].
  const ChatService();

  /// Processes [input] and returns the bot response after a short delay.
  Future<Message> processInput(String input) async {
    await Future.delayed(
      const Duration(milliseconds: _responseDelayMs),
    );
    return Message(
      content: _responseText,
      timestamp: DateTime.now(),
      isUser: false,
    );
  }
}
