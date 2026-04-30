import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageSender { user, agent, system }

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String content,

    required int timestamp,

    required MessageSender sender,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
