import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/message.dart';

part 'context_provider.g.dart';

@riverpod
final class Context extends _$Context {
  @override
  List<Message> build() => const [];

  void add(Message message) => state = [...state, message];

  Message get last => state.last;
}
