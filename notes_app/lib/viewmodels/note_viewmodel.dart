import 'package:flutter/material.dart';
import 'dart:io';
import '../models/note.dart';
import '../services/supabase_service.dart';
import '../services/note_database.dart';
final supabase = SupabaseService();

class NoteViewModel extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    _notes = await supabase.fetchNotes();
    notifyListeners();
    await _syncNotesFolder();
  }

  Future<void> addNote(Note note) async {
    final now = DateTime.now();
    final localNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      tags: note.tags,
      createdAt: now,
      updatedAt: now,
      userId: note.userId,
    );
    _notes.insert(0, localNote);
    notifyListeners();

    try {
      await supabase.upsertNote(localNote);
      await NoteDatabase.insertNote(localNote);
      await loadNotes();
    } catch (e) {}
  }

  Future<void> updateNote(Note note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      final updated = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        tags: note.tags,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
        userId: note.userId,
      );
      _notes[idx] = updated;
      notifyListeners();

      try {
        await supabase.upsertNote(updated);
        await NoteDatabase.updateNote(updated);
        await loadNotes();
      } catch (e) {}
    }
  }

  Future<void> deleteNote(int id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _deleteNoteFileById(id);

    try {
      await supabase.deleteNote(id);
      await loadNotes();
    } catch (e) {}
  }

  List<Note> getNotesByTag(String tag) {
    return _notes.where((n) => n.tags.contains(tag)).toList();
  }

  // Synchronise le dossier notes avec la liste _notes
  Future<void> _syncNotesFolder() async {
    final notesDir = Directory('${Directory.current.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    // 1. Supprime tous les fichiers .md qui ne correspondent plus à une note
    final existingFiles = notesDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();

    final validFilenames = _notes.map((note) => _getNoteFileName(note)).toSet();

    for (final file in existingFiles) {
      final filename = file.uri.pathSegments.last;
      if (!validFilenames.contains(filename)) {
        await file.delete();
      }
    }
    // 2. (Re)crée tous les fichiers .md pour chaque note
    for (final note in _notes) {
      await _exportNoteToFile(note);
    }
  }

  // Génère le nom de fichier pour une note
  String _getNoteFileName(Note note) {
    String safeTitle = note.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (safeTitle.isEmpty) safeTitle = 'note';
    String safeTag = note.tags.isNotEmpty
        ? note.tags.first.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim()
        : 'no_tag';
    String dateStr = '';
    try {
      final date = note.updatedAt;
      dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      dateStr = 'date';
    }
    return '$safeTitle ($safeTag) $dateStr.md';
  }

  // Exporte une note en .md
  Future<void> _exportNoteToFile(Note note) async {
    final notesDir = Directory('${Directory.current.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    final fileName = _getNoteFileName(note);
    final file = File('${notesDir.path}/$fileName');
    final content = '''
# ${note.title}

Tags: ${note.tags.join(', ')}

Créé le: ${note.createdAt}
Modifié le: ${note.updatedAt}

---

${note.content}
''';
    await file.writeAsString(content);
  }

  // Supprime le fichier .md d'une note supprimée
  Future<void> _deleteNoteFileById(int id) async {
    final notesDir = Directory('${Directory.current.path}/notes');
    if (!await notesDir.exists()) return;
    // Cherche la note supprimée dans la liste précédente (avant suppression)
    // ou supprime tous les fichiers qui contiennent l'id dans leur nom (fallback)
    final files = notesDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();
    for (final file in files) {
      // Option : supprime tous les fichiers qui contiennent l'id dans le nom
      if (file.path.contains('($id)')) {
        await file.delete();
      }
    }
  }
}

