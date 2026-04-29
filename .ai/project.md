# p7t_cli Project Requirements

## Overview
Barebone proof-of-concept Dart terminal chat app in `./packages/p7t_cli`.

## Functional Requirements
- Launch a terminal-based chat with the user.
- Prompt: `what can I do for you`.
- For any user input, reply `it will be done` after exactly 500ms.
- Exit on Ctrl+C (OS signal) or EOF.

## Non-Functional Requirements
- **No runtime dependencies** (only `test` in `dev_dependencies`).
- **100% code coverage** on `lib/` via unit tests.
- **Clean code**: DRY, Single Responsibility Principle, TDD approach.
- **Concise comments**: max 80 chars per comment line on every class, function, and variable.
- Inspired by `termkit` and `utopia_tui` architecture patterns.

## Architecture
- `Message`: immutable value object (content, timestamp, isUser).
- `ChatService`: pure business logic, 500ms delay, fixed response.
- `TerminalIO`: abstract I/O boundary.
- `StdioTerminalIO`: concrete `stdin`/`stdout` implementation.
- `ChatRunner`: orchestrates the read-eval-print loop.
- `App`: composition root wiring real implementations.

## Testing Strategy
- Unit test every public class and method.
- Fake `TerminalIO` for `ChatRunner` tests.
- Inject fake functions into `StdioTerminalIO` for coverage.
- Use `Stopwatch` to assert the 500ms delay in `ChatService`.
- Run `dart test --coverage` and verify 100% line coverage.
