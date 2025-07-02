import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import 'dart:io';

class NoteDatabase {
  static Database? _db;

  static Future<void> init() async {
    sqfliteFfiInit();
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'notes.db');

    _db = await databaseFactoryFfi.openDatabase(path, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            tags TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    ));
  }

  static Future<List<Note>> getNotes() async {
    final maps = await _db!.query('notes', orderBy: 'updatedAt DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  static Future<int> insertNote(Note note) async {
    return await _db!.insert('notes', note.toMap());
  }

  static Future<int> updateNote(Note note) async {
    return await _db!.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<void> deleteNote(int id) async {
    await _db!.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
