import 'package:flutter/material.dart';
import '../models/note.dart';
import '../views/editor_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/note_viewmodel.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NoteViewModel>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(
          note.content.length > 100
              ? '${note.content.substring(0, 100)}...'
              : note.content,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => viewModel.deleteNote(note.id!),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditorView(note: note)),
        ),
      ),
    );
  }
}
