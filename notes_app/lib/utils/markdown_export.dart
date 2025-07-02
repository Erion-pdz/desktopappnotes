import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> exportNoteAsMarkdown(String title, String content) async {
  final directory = await FilePicker.platform.getDirectoryPath();
  if (directory != null) {
    final file = File('$directory/$title.md');
    await file.writeAsString(content);
  }
}
