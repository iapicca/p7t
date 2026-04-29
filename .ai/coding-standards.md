# Coding Standards for p7t

---

## 1. Naming Conventions

### 1.1 Abstractions
- **Suffix abstract classes with `Interface`**  
  e.g. `TerminalInterface`, `AgentInterface` — not `TerminalIO`, `ChatService`.

### 1.2 Implementations
- Name mocks/stubs with the interface name + `Mock`  
  e.g. `AgentInterfaceMock` (not `MockAgent`).
- Use domain-specific names for orchestrators  
  e.g. `Workflow` instead of `ChatRunner`, `App`, or `Runner`.

### 1.3 Methods & APIs
- Prefer domain verbs over generic CRUD  
  e.g. `ask(List<Message>)` over `processInput(String)`.

---

## 2. Architecture Patterns

### 2.1 Reactive State Management
- Use **`ValueNotifier<T>`** (or Flutter equivalent) for observable state.
- Drive logic through **listeners/callbacks**, not imperative `async/await` loops.
- State changes should trigger side effects via listener pattern.

### 2.2 Input/Output Boundaries
- Model external input as **`Stream<T>`**  
  e.g. `Stream<String> get input` instead of `String? readLine()`.
- This enables reactive composition and natural backpressure handling.

### 2.3 State Machines / Event-Driven Flow
- Prefer **state-machine-like** transitions over linear REPL loops.
- Use `switch` on enums to dispatch behavior based on state.

---

## 3. Data Models

### 3.1 Immutable Value Objects
- Use **`freezed`** with `@freezed` annotation for all data classes.
- Always include `part` directives for generated code:
  ```dart
  part 'message.freezed.dart';
  part 'message.g.dart';
  ```

### 3.2 Timestamps
- Store timestamps as **`int`** (Unix epoch, microseconds or milliseconds UTC).
- Use `DateTime.now().toUtc().microsecondsSinceEpoch` or `millisecondsSinceEpoch`.
- Never store `DateTime` objects directly in models.

### 3.3 Enums Over Booleans
- Use explicit **`enum`** types instead of boolean flags  
  e.g. `MessageSender { user, agent }` instead of `bool isUser`.

### 3.4 JSON Serialization
- Always include `fromJson` / `toJson` via `json_serializable`, even if not immediately consumed.

---

## 4. Language Features

### 4.1 Class Modifiers
- Mark implementation classes as **`final class`** to prevent inheritance.
- Use `abstract class` + `const` constructors for interfaces.

### 4.2 Constructors
- Use **`const` constructors** wherever possible.
- Use **`const factory`** for redirecting constructors (e.g., `const factory X.stdio() = _XStdio`).

### 4.3 Fields
- Use `late final` for fields initialized after construction but before use.
- Use `_` prefix for all private members.

### 4.4 Functions
- Use **arrow syntax `=>`** for single-line methods and simple Future chains.
- Avoid unnecessary braces for one-liners.

---

## 5. Code Organization

### 5.1 Package Structure
- Place shared internal packages under `./internal/` (not `./packages/`).
- `./packages/` is for publishable/external-facing packages only.

### 5.2 Imports
- Use **show** clauses for selective imports from `dart:` libraries  
  e.g. `import 'dart:convert' show utf8, LineSplitter;`.

### 5.3 Spacing & Comments
- **No blank lines** between logically grouped class members.
- Only comment **public APIs** — private methods/fields generally do not need doc comments.
- Keep comments concise and purposeful; avoid redundant "getter/setter" descriptions.

---

## 6. Dependencies

### 6.1 Code Generation
- Always include **code generation toolchain** when data models are involved:
  - `freezed`, `freezed_annotation`
  - `json_serializable`, `json_annotation`
  - `build_runner`
  - `custom_lint`, `freezed_lint`

### 6.2 Linting
- Use **`lints: ^3.0.0`** (or latest) instead of `package:test/analysis_options.yaml`.
- Exclude generated files in `analysis_options.yaml`:
  ```yaml
  analyzer:
    exclude:
      - "**/*.g.dart"
      - "**/*.freezed.dart"
  ```

### 6.3 Internal Packages
- Create small, focused internal packages for reusable primitives (e.g., `value_notifier`).
- Reference them via `path:` dependency.

---

## 7. Entry Points

- Keep **`main()` minimal** — ideally just constructing the top-level object.
- Do not add explicit `.run()` or `.init()` calls in `main()` unless absolutely necessary.
- Example:
  ```dart
  Future<void> main() async {
    Workflow(
      agent: const AgentInterfaceMock(),
      terminal: const TerminalInterface.stdio(),
    );
  }
  ```

---

## 8. Testing Philosophy

- During **prototyping / major refactors**, it is acceptable to **delete obsolete tests** and rewrite them from scratch rather than forcing old tests onto new architecture.
- Tests should validate the **reactive behavior** (state transitions, listener calls) rather than imperative sequences.
- Use fake/stub implementations that implement the `Interface` directly.

---

## 9. Anti-Patterns to Avoid

| Avoid | Prefer |
|---|---|
| `String? readLine()` | `Stream<String> get input` |
| `bool isUser` | `enum MessageSender { user, agent }` |
| `DateTime timestamp` | `int timestamp` (Unix epoch) |
| Manual immutable classes | `@freezed` generated classes |
| Generic names (`App`, `Runner`, `Service`) | Domain names (`Workflow`, `AgentInterface`) |
| Imperative `while(true)` loops | Reactive `ValueNotifier` + listeners |
| Comments on private `_` members | Comments only on public APIs |
| Blank lines between every member | Dense, logically grouped code |
