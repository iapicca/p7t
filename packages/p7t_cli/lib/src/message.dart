import 'package:freezed_annotation/freezed_annotation.dart';

// These part directives are required for freezed and json_serializable code generation.
part 'message.freezed.dart';
part 'message.g.dart';

/// Defines who sent the message.
enum MessageSender { user, agent }

/// Immutable value object representing a single chat message.
@freezed
class Message with _$Message {
  const factory Message({
    /// The textual content of this message.
    required String content,

    /// When this message was created (Unix time UTC).
    required int timestamp,

    /// Whether the message was sent by the user or the agent.
    required MessageSender sender,
  }) = _Message;

  /// Creates a [Message] from a JSON object.
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
