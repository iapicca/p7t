/// Terminal chat application library.
///
/// Exports the core classes needed to build or extend a `p7t`
/// command-line interface:
///
/// * [Workflow] – orchestrates the chat loop.
/// * [TerminalInterface] – abstracts terminal I/O.
/// * [AgentInterface] – abstracts the conversational agent.
library;

export 'src/workflow.dart';
export 'src/terminal_interface.dart';
export 'src/agent_interface.dart';
