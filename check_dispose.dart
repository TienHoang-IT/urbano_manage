import 'dart:io';
void main() {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final content = file.readAsStringSync();
    if (!content.contains('TextEditingController') && !content.contains('FocusNode')) continue;
    final controllerRegex = RegExp(r'(?:final|var|TextEditingController|FocusNode)\s+([a-zA-Z0-9_]+)\s*=\s*(?:TextEditingController|FocusNode)\(');
    final matches = controllerRegex.allMatches(content);
    final missing = <String>[];
    for (final match in matches) {
      final varName = match.group(1)!;
      if (!content.contains('.dispose()')) {
        missing.add(varName);
      }
    }
    if (missing.isNotEmpty) {
      print('${file.path}: Missing dispose for $missing');
    }
  }
}
