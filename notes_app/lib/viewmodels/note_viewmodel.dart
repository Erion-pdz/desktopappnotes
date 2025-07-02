import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';
final supabase = SupabaseService();

class NoteViewModel extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;
Future<void> loadNotes() async {
  _notes = await supabase.fetchNotes(); // cloud uniquement
  notifyListeners();
}

Future<void> addNote(Note note) async {
  await supabase.upsertNote(note);
  await loadNotes();
}

Future<void> updateNote(Note note) async {
  await supabase.upsertNote(note);
  await loadNotes();
}

Future<void> deleteNote(int id) async {
  await supabase.deleteNote(id);
  await loadNotes();
}


  List<Note> getNotesByTag(String tag) {
    return _notes.where((n) => n.tags.contains(tag)).toList();
  }
}
