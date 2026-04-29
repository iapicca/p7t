/// A pure Dart equivalent to Flutter's [ValueNotifier].
///
/// Holds a single value and notifies registered listeners whenever that
/// value changes.  The identity comparison `==` is used to decide whether
/// a newly assigned value is different from the current one.
///
/// ```dart
/// final notifier = ValueNotifier(0);
/// notifier.addListener(() => print(notifier.value));
/// notifier.value = 42; // prints 42
/// ```
class ValueNotifier<T> {
  /// The current value held by this notifier.
  T _value;

  /// Registered callbacks that are invoked when [value] changes.
  final Set<void Function()> _listeners = {};

  /// Creates a [ValueNotifier] with the given initial [value].
  ValueNotifier(this._value);

  /// The current value.
  ///
  /// Setting a new value that is not equal to the current one (using `==`)
  /// notifies all registered listeners.
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    _notifyListeners();
  }

  /// Adds [listener] to the set of callbacks that are invoked whenever
  /// [value] changes.
  ///
  /// Because listeners are stored in a [Set], adding the exact same
  /// function reference more than once has no effect.
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Removes [listener] from the set of callbacks.
  ///
  /// If [listener] was added multiple times, only a single instance is
  /// removed.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners.
  ///
  /// Listeners are called in the order they were added.
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Discards all registered listeners.
  ///
  /// After calling [dispose], the notifier will no longer notify any
  /// listeners and the underlying set is cleared.
  void dispose() {
    _listeners.clear();
  }
}
