import 'package:p7t_cli/p7t_cli.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    test('stores content, timestamp, and isUser flag', () {
      final now = DateTime.now();
      const content = 'hello';
      const isUser = true;

      final message = Message(
        content: content,
        timestamp: now,
        isUser: isUser,
      );

      expect(message.content, content);
      expect(message.timestamp, now);
      expect(message.isUser, isUser);
    });

    test('supports bot message construction', () {
      final now = DateTime(2024, 1, 1);
      final message = Message(
        content: 'bot reply',
        timestamp: now,
        isUser: false,
      );

      expect(message.content, 'bot reply');
      expect(message.isUser, isFalse);
      expect(message.timestamp, now);
    });
  });
}
