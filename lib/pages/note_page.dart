import 'package:flutter/material.dart';
import '../notes/note.dart';
import '../notes/note_hive_database.dart';
import '/auth/auth_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final authService = AuthService();
  final notesDatabase = HiveNoteDatabase();
  final noteController = TextEditingController();
  final titleController = TextEditingController();

  void addNewNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Note"),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              decoration: InputDecoration(
                labelText: 'Notes',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              noteController.clear();
              titleController.clear();
            },
            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNote = Note(
                userId: authService.getCurrentUserId().toString(),
                title: titleController.text,
                content: noteController.text,
                isDone: false,
              );
              await notesDatabase.addNote(newNote);
              Navigator.pop(context);
              noteController.clear();
              titleController.clear();
              setState(() {});
            },
            child: const Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void updateNote(int key, Note note) {
    titleController.text = note.title;
    noteController.text = note.content;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Note"),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              decoration: InputDecoration(
                labelText: 'Notes',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              noteController.clear();
            },
            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedNote = Note(
                userId: note.userId,
                title: titleController.text,
                content: noteController.text,
                isDone: note.isDone,
              );
              await notesDatabase.updateNote(key, updatedNote);
              Navigator.pop(context);
              titleController.clear();
              noteController.clear();
              setState(() {});
            },
            child: const Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void deleteNote(int key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              noteController.clear();
              titleController.clear();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await notesDatabase.deleteNote(key);
              Navigator.pop(context);
              noteController.clear();
              titleController.clear();
              setState(() {});
            },
            child: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = authService.getCurrentUserId().toString();
    return Scaffold(
      appBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewNote(),
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        child: const Icon(Icons.add, size: 30),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>('notesBox').listenable(),
        builder: (context, Box<Note> box, _) {
          final notes = box.values.toList();
          if (notes.isEmpty) {
            return Center(
              child: Text(
                "No notes available.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final key = box.keyAt(index) as int;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  leading: Checkbox(
                    value: note.isDone,
                    onChanged: (value) async {
                      final updatedNote = Note(
                        userId: note.userId,
                        title: note.title,
                        content: note.content,
                        isDone: value ?? false,
                      );
                      await notesDatabase.updateNote(key, updatedNote);
                      setState(() {});
                    },
                  ),
                  title: Text(
                    note.title,
                    style: TextStyle(
                      color: note.isDone
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                      decoration: note.isDone ? TextDecoration.lineThrough : null,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    note.content,
                    style: TextStyle(
                      color: note.isDone
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      decoration: note.isDone ? TextDecoration.lineThrough : null,
                      fontSize: 15,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => updateNote(key, note),
                          icon: const Icon(Icons.edit),
                          color: Colors.amberAccent,
                        ),
                        IconButton(
                          onPressed: () => deleteNote(key),
                          icon: const Icon(Icons.delete),
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
