import 'package:p7t_cli/p7t_cli.dart';

/// Entry point for the p7t_cli executable.
Future<void> main() async {
  final app = App();
  await app.run();
}
