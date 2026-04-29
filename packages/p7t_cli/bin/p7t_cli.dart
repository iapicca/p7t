import 'dart:io' show ProcessSignal, exit;

import 'package:p7t_cli/p7t_cli.dart';

/// Entry point for the `p7t` CLI.
///
/// Creates a [Workflow] backed by [AgentInterfaceMock] and
/// [DartTuiInterface], starts it, and listens for `SIGINT`
/// to perform graceful shutdown.
///
/// The process also exits cleanly when the user presses **q** or
/// **Ctrl+C** inside the TUI.
Future<void> main() async {
  final tui = DartTuiInterface();
  final workflow = Workflow(
    agent: const AgentInterfaceMock(),
    tui: tui,
  );
  await workflow.init();

  ProcessSignal.sigint.watch().listen(
    (signal) => workflow.dispose().then((_) => exit(0)),
  );

  // Wait for the TUI to finish (user pressed q / Ctrl+C inside the app).
  await tui.done;
  await workflow.dispose();
}
