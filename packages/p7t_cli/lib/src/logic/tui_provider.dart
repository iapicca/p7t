import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:value_notifier/value_notifier.dart';
import 'package:dart_tui/dart_tui.dart' as ui;

import '../domain/terminal_interface.dart';

part 'tui_provider.g.dart';

typedef BuildContext = Future<ui.Model> Function(ui.Model);

@riverpod
BuildContext tui(Ref ref) {
  late final input = ValueNotifier<String>('');
  late final program = ui.Program(
    options: const ui.ProgramOptions(altScreen: true, hideCursor: true),
    programOptions: [ui.withTickInterval(const Duration(milliseconds: 100))],
  );

  ref.onDispose(() {
    input.dispose();
    program.quit();
  });

  return program.run;
}
