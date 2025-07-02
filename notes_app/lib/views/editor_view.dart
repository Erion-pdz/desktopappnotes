import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as flutter_provider;

import '../models/note.dart';
import '../viewmodels/note_viewmodel.dart';
import '../utils/markdown_export.dart';

class EditorView extends StatefulWidget {
  final Note? note;

  const EditorView({super.key, this.note});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late TextEditingController titleCtrl;
  late TextEditingController contentCtrl;
  late TextEditingController tagsCtrl;
  bool previewMode = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    tagsCtrl = TextEditingController(text: widget.note?.tags.join(', ') ?? '');
  }

  Future<void> saveNote(BuildContext context) async {
    final viewModel = flutter_provider.Provider.of<NoteViewModel>(context, listen: false);
    final isEditing = widget.note != null;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : utilisateur non connecté')),
      );
      return;
    }

    if (titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le titre ne peut pas être vide.")),
      );
      return;
    }

    final note = Note(
      id: widget.note?.id,
      title: titleCtrl.text.trim(),
      content: contentCtrl.text.trim(),
      tags: tagsCtrl.text.split(',').map((e) => e.trim()).toList(),
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      userId: userId,
    );

    if (isEditing) {
      await viewModel.updateNote(note);
    } else {
      await viewModel.addNote(note);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la note' : 'Nouvelle note'),
        actions: [
          IconButton(
            icon: Icon(previewMode ? Icons.edit : Icons.visibility),
            onPressed: () => setState(() => previewMode = !previewMode),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Le titre est requis pour exporter.")),
                );
                return;
              }
              await exportNoteAsMarkdown(titleCtrl.text.trim(), contentCtrl.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note exportée en .md")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => saveNote(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: tagsCtrl,
              decoration: const InputDecoration(labelText: 'Tags (séparés par des virgules)'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: previewMode
                  ? Markdown(data: contentCtrl.text)
                  : TextField(
                      controller: contentCtrl,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        labelText: 'Contenu (Markdown)',
                        border: OutlineInputBorder(),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(isEditing ? 'Mettre à jour la note' : 'Enregistrer la note'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => saveNote(context),
            ),
          ),
        ],
      ),
    );
  }
}
