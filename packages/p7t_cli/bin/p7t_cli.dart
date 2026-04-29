import 'dart:io' show ProcessSignal;

import 'package:p7t_cli/p7t_cli.dart';

void main() {
  final workflow = Workflow(
    agent: const AgentInterfaceMock(),
    terminal: const TerminalInterface.stdio(),
  );

  ProcessSignal.sigint.watch().listen((signal) => workflow.dispose());
  workflow.init();
}
