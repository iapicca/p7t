import 'package:test/test.dart';
import 'package:value_notifier/value_notifier.dart';

void main() {
  group('ValueNotifier', () {
    test('constructor stores initial value', () {
      final notifier = ValueNotifier(42);
      expect(notifier.value, 42);
    });

    test('setter updates value', () {
      final notifier = ValueNotifier(0);
      notifier.value = 10;
      expect(notifier.value, 10);
    });

    test('setter notifies listeners on change', () {
      final notifier = ValueNotifier('a');
      var called = 0;
      notifier.addListener(() => called++);
      notifier.value = 'b';
      expect(called, 1);
    });

    test('setter does not notify when value is equal', () {
      final notifier = ValueNotifier(5);
      var called = 0;
      notifier.addListener(() => called++);
      notifier.value = 5;
      expect(called, 0);
    });

    test('multiple listeners are notified', () {
      final notifier = ValueNotifier(0);
      var a = 0, b = 0;
      notifier.addListener(() => a++);
      notifier.addListener(() => b++);
      notifier.value = 1;
      expect(a, 1);
      expect(b, 1);
    });

    test('duplicate listener references are deduplicated', () {
      final notifier = ValueNotifier(0);
      var count = 0;
      void listener() => count++;
      notifier.addListener(listener);
      notifier.addListener(listener);
      notifier.value = 1;
      expect(count, 1);
    });

    test('removeListener removes the listener entirely', () {
      final notifier = ValueNotifier(0);
      var count = 0;
      void listener() => count++;
      notifier.addListener(listener);
      notifier.removeListener(listener);
      notifier.value = 1;
      expect(count, 0);
    });

    test('removeListener on unknown listener is a no-op', () {
      final notifier = ValueNotifier(0);
      notifier.removeListener(() {});
      notifier.value = 1;
      // No exception expected.
    });

    test('dispose clears listeners', () {
      final notifier = ValueNotifier(0);
      var called = 0;
      notifier.addListener(() => called++);
      notifier.dispose();
      notifier.value = 1;
      expect(called, 0);
    });

    test('listeners receive the new value via getter', () {
      final notifier = ValueNotifier(0);
      late int observed;
      notifier.addListener(() => observed = notifier.value);
      notifier.value = 99;
      expect(observed, 99);
    });
  });
}
