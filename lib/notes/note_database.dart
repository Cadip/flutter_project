import 'note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteDatabase {
  final database = Supabase.instance.client.from('notes');

  Future createNote(Note newNote) async {
    await database.insert(newNote.toMap());
  }

  Stream<List<Note>> stream(String userId) {
    return Supabase.instance.client
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          final list = (data as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          );
          return list.map((noteMap) => Note.fromMap(noteMap)).toList();
        });
  }

  Future updateNote(Note oldNote, String newTitle, String newContent) async {
    await database
        .update({'title': newTitle, 'content': newContent})
        .eq('id', oldNote.id!);
  }

  Future deleteNote(Note note) async {
    await database.delete().eq('id', note.id!);
  }

  Future updateStatus(Note note, bool isDone) async {
    await database.update({'is_done': isDone}).eq('id', note.id!);
  }
}
