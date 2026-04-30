import 'package:dart_tui/dart_tui.dart' as ui;

final class TuiModel extends ui.Model {
  TuiModel({
    required this.onUserInput,
    required this.onQuit,
    this.messages = const [],
    this.busy = false,
    TextInputModel? textInput,
    SpinnerModel? spinner,
    this.windowWidth = 80,
    this.windowHeight = 24,
  }) : textInput =
           textInput ??
           TextInputModel(
             placeholder: 'Type a message…',
             styles: const InputStyles(
               text: Style(foregroundRgb: RgbColor(205, 214, 244)),
               placeholder: Style(
                 foregroundRgb: RgbColor(108, 112, 134),
                 isDim: true,
                 isItalic: true,
               ),
             ),
           ),
       spinner = spinner ?? SpinnerModel();

  final void Function(String) onUserInput;
  final void Function() onQuit;
  final List<Message> messages;
  final bool busy;
  final TextInputModel textInput;
  final SpinnerModel spinner;
  final int windowWidth;
  final int windowHeight;

  _ChatTuiModel copyWith({
    List<Message>? messages,
    bool? busy,
    TextInputModel? textInput,
    SpinnerModel? spinner,
    int? windowWidth,
    int? windowHeight,
  }) => _ChatTuiModel(
    onUserInput: onUserInput,
    onQuit: onQuit,
    messages: messages ?? this.messages,
    busy: busy ?? this.busy,
    textInput: textInput ?? this.textInput,
    spinner: spinner ?? this.spinner,
    windowWidth: windowWidth ?? this.windowWidth,
    windowHeight: windowHeight ?? this.windowHeight,
  );

  @override
  (Model, Cmd?) update(Msg msg) {
    if (msg is _DisplayMessageMsg) {
      return (copyWith(messages: [...messages, msg.message]), null);
    }

    if (msg is _SetBusyMsg) {
      return (copyWith(busy: msg.busy), null);
    }

    if (msg is WindowSizeMsg) {
      return (copyWith(windowWidth: msg.width, windowHeight: msg.height), null);
    }

    if (msg is KeyMsg) {
      if (msg.key == 'ctrl+c' || msg.key == 'q') {
        onQuit();
        return (this, () => QuitMsg());
      }

      if (msg.key == 'enter') {
        final value = textInput.value.trim();
        if (value.isNotEmpty) {
          onUserInput(value);
          return (
            copyWith(
              textInput: TextInputModel(
                placeholder: textInput.placeholder,
                styles: textInput.styles,
              ),
            ),
            null,
          );
        }
        return (this, null);
      }

      final (nextInput, inputCmd) = textInput.update(msg);
      return (copyWith(textInput: nextInput as TextInputModel), inputCmd);
    }

    if (msg is PasteMsg) {
      final chars = textInput.value.characters.toList();
      final pasteChars = msg.content.characters.toList();
      final nextChars = List<String>.from(chars)
        ..insertAll(textInput.cursorPos, pasteChars);
      return (
        copyWith(
          textInput: textInput.copyWith(
            value: nextChars.join(),
            cursorPos: textInput.cursorPos + pasteChars.length,
          ),
        ),
        null,
      );
    }

    if (msg is TickMsg && busy) {
      final (nextSpinner, spinnerCmd) = spinner.update(msg);
      return (copyWith(spinner: nextSpinner as SpinnerModel), spinnerCmd);
    }

    return (this, null);
  }

  @override
  View view() {
    final messageBlocks = <String>[];
    for (final message in messages) {
      final isUser = message.sender == MessageSender.user;
      final style = Style(
        foregroundRgb: isUser
            ? const RgbColor(137, 180, 250) // blue
            : const RgbColor(166, 227, 161), // green
        border: Border.rounded,
        borderForeground: isUser
            ? const RgbColor(137, 180, 250)
            : const RgbColor(166, 227, 161),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 1),
        align: isUser ? Align.right : Align.left,
        width: windowWidth - 4,
        wordWrap: true,
      );
      messageBlocks.add(style.render(message.content));
    }

    final spinnerBlock = busy ? spinner.view().content : '';

    final inputView = textInput.view();
    final inputContent = textInput.value.isEmpty
        ? const Style(
            foregroundRgb: RgbColor(108, 112, 134),
            isDim: true,
            isItalic: true,
          ).render(textInput.placeholder)
        : inputView.content;
    final inputStyle = Style(
      border: Border.rounded,
      borderForeground: RgbColor(108, 112, 134),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 1),
      width: windowWidth - 2,
    );
    final inputBlock = inputStyle.render(inputContent);

    final hintStyle = const Style(
      foregroundRgb: RgbColor(108, 112, 134),
      isDim: true,
      isItalic: true,
    );
    final hintBlock = hintStyle.render('Press Ctrl+C or q to exit');

    final blocks = <String>[
      ...messageBlocks,
      if (spinnerBlock.isNotEmpty) spinnerBlock,
      inputBlock,
      hintBlock,
    ];
    final content = blocks.join('\n');

    Cursor? cursor;
    if (inputView.cursor != null) {
      var cursorY = 0;
      for (final block in messageBlocks) {
        cursorY += getHeight(block);
      }
      if (spinnerBlock.isNotEmpty) {
        cursorY += getHeight(spinnerBlock);
      }
      // +1 for the top border of the input box
      cursorY += 1;

      final cursorX = 2 + inputView.cursor!.x;

      cursor = Cursor(
        x: cursorX,
        y: cursorY,
        shape: CursorShape.bar,
        blink: true,
      );
    }

    return View(content: content, cursor: cursor);
  }
}
