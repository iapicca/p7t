import 'package:p7t_cli/p7t_cli.dart';
import 'package:test/test.dart';

void main() {
  group('ChatService', () {
    const service = ChatService();

    test('returns "it will be done" after at least 500ms', () async {
      final stopwatch = Stopwatch()..start();
      final message = await service.processInput('hello');
      stopwatch.stop();

      expect(message.content, 'it will be done');
      expect(message.isUser, isFalse);
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
    });

    test('ignores input content and always replies the same', () async {
      final message1 = await service.processInput('foo');
      final message2 = await service.processInput('bar');

      expect(message1.content, message2.content);
      expect(message1.isUser, isFalse);
      expect(message2.isUser, isFalse);
    });

    test('timestamp is set to a recent DateTime', () async {
      final before = DateTime.now();
      final message = await service.processInput('test');
      final after = DateTime.now();

      expect(message.timestamp.isAfter(before), isTrue);
      expect(message.timestamp.isBefore(after), isTrue);
    });
  });
}
