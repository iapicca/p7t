/// Immutable value object representing a single chat message.
class Message {
  /// The textual content of this message.
  final String content;

  /// When this message was created.
  final DateTime timestamp;

  /// True if sent by the user, false if sent by the bot.
  final bool isUser;

  /// Creates a new [Message] with the given properties.
  const Message({
    required this.content,
    required this.timestamp,
    required this.isUser,
  });
}
