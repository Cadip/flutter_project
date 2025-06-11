import 'package:hive/hive.dart';
import 'note.dart';

class HiveNoteDatabase {
  static const String boxName = 'notesBox';

  Future<void> openBox() async {
    await Hive.openBox<Note>(boxName);
  }

  Future<void> addNote(Note note) async {
    final box = Hive.box<Note>(boxName);
    await box.add(note);
  }

  List<Note> getNotes() {
    final box = Hive.box<Note>(boxName);
    return box.values.toList();
  }

  Future<void> updateNote(int key, Note note) async {
    final box = Hive.box<Note>(boxName);
    await box.put(key, note);
  }

  Future<void> deleteNote(int key) async {
    final box = Hive.box<Note>(boxName);
    await box.delete(key);
  }

  void close() {
    Hive.box<Note>(boxName).close();
  }
}
