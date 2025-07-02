import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  Future<void> upsertNote(Note note) async {
    final data = {
      'title': note.title,
      'content': note.content,
      'tags': note.tags.join(','),
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
      'user_id': note.userId,
    };

    final id = note.id;
    if (id != null) {
      data['id'] = id.toString(); // Correction ici
    }

    // upsert attend une liste de maps
    await client.from('notes').upsert([data]);
  }

  Future<void> deleteNote(int id) async {
    await client.from('notes').delete().eq('id', id);
  }

  Future<List<Note>> fetchNotes() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await client
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('updatedAt', ascending: false);

    // res peut être List<dynamic> ou PostgrestResponse, on gère les deux cas
    if (res is List) {
      return res.map((e) => Note.fromMap(e)).toList();
    }
    return [];
  }
}
