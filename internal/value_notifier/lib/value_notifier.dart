/// A pure Dart equivalent to Flutter's ValueNotifier.
class ValueNotifier<T> {
  T _value;
  final Set<void Function()> _listeners = {};

  ValueNotifier(this._value);

  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    _notifyListeners();
  }

  /// Adds a callback that runs whenever [value] changes.
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered callback.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Discards resources used by the object.
  void dispose() {
    _listeners.clear();
  }
}
