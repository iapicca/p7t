/// Terminal chat application library.
///
/// Exports the core classes needed to build or extend a `p7t`
/// command-line interface:
///
/// * [Workflow] – orchestrates the chat loop.
/// * [TuiInterface] – abstracts terminal UI interactions.
/// * [DartTuiInterface] – [TuiInterface] backed by `dart_tui`.
/// * [AgentInterface] – abstracts the conversational agent.
library;

export 'src/workflow.dart';
export 'src/domain/terminal_interface.dart';
export 'src/dart_tui_interface.dart';
export 'src/domain/agent_interface.dart';
