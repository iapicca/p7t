import 'dart:io' show ProcessSignal, exit;

import 'package:p7t_cli/p7t_cli.dart';

/// Entry point for the `p7t` CLI.
///
/// Creates a [Workflow] backed by [AgentInterfaceMock] and
/// [TerminalInterface.stdio], starts it, and listens for `SIGINT`
/// to perform graceful shutdown.
void main() async {
  final workflow = Workflow(
    agent: const AgentInterfaceMock(),
    terminal: const TerminalInterface.stdio(),
  );
  await workflow.init();
  ProcessSignal.sigint.watch().listen(
    (signal) => workflow.dispose().then((_) => exit(0)),
  );
}
