import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status_provider.g.dart';

@riverpod
final class Status extends _$Status {
  @override
  bool build() => false;

  set busy(bool busy) => state = busy;

  bool get busy => state;
}
