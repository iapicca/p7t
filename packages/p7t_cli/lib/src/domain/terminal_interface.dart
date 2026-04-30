import 'package:value_notifier/value_notifier.dart';

import 'message.dart';

typedef Write = void Function(Message);

final class TerminalUserInterface {
  const TerminalUserInterface({required this.write, required this.input});
  final Write write;
  final ValueNotifier<String> input;
}
