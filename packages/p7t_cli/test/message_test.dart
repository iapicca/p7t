import 'package:p7t_cli/src/domain/message.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    const message = Message(
      content: 'hello',
      timestamp: 1234567890,
      sender: MessageSender.user,
    );

    test('holds values', () {
      expect(message.content, 'hello');
      expect(message.timestamp, 1234567890);
      expect(message.sender, MessageSender.user);
    });

    test('equality', () {
      const other = Message(
        content: 'hello',
        timestamp: 1234567890,
        sender: MessageSender.user,
      );
      expect(message, other);
    });

    test('inequality for different fields', () {
      expect(
        message,
        isNot(
          const Message(
            content: 'world',
            timestamp: 1234567890,
            sender: MessageSender.user,
          ),
        ),
      );
      expect(
        message,
        isNot(
          const Message(
            content: 'hello',
            timestamp: 0,
            sender: MessageSender.user,
          ),
        ),
      );
      expect(
        message,
        isNot(
          const Message(
            content: 'hello',
            timestamp: 1234567890,
            sender: MessageSender.agent,
          ),
        ),
      );
    });

    test('copyWith overrides fields', () {
      final updated = message.copyWith(content: 'world');
      expect(updated.content, 'world');
      expect(updated.timestamp, message.timestamp);
      expect(updated.sender, message.sender);
    });

    test('toJson / fromJson round-trip', () {
      final json = message.toJson();
      final restored = Message.fromJson(json);
      expect(restored, message);
    });

    test('json includes all senders', () {
      for (final sender in MessageSender.values) {
        final m = Message(content: 'x', timestamp: 1, sender: sender);
        final restored = Message.fromJson(m.toJson());
        expect(restored.sender, sender);
      }
    });
  });
}
