import 'package:flutter/material.dart';
import '../notes/note.dart';
import '../notes/note_database.dart';
import '/auth/auth_service.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final authService = AuthService();
  final notesDatabase = NoteDatabase();
  final noteController = TextEditingController();
  final titleController = TextEditingController();

  void addNewNote() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Note"),
            backgroundColor: Colors.green,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  noteController.clear();
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  final newNote = Note(
                    userId: authService.getCurrentUserId().toString(),
                    title: titleController.text,
                    content: noteController.text,
                    isDone: false,
                  );
                  notesDatabase.createNote(newNote);
                  Navigator.pop(context);
                  noteController.clear();
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void updateNote(Note note) {
    titleController.text = note.title;
    noteController.text = note.content;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Update Note"),
            backgroundColor: Colors.yellowAccent,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Notes'),
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
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  notesDatabase.updateNote(
                    note,
                    titleController.text,
                    noteController.text,
                  );
                  Navigator.pop(context);
                  noteController.clear();
                  titleController.clear();
                },
                child: const Text("Save", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  void deleteNote(Note note) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Note"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  noteController.clear();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  notesDatabase.deleteNote(note);
                  Navigator.pop(context);
                  noteController.clear();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = authService.getCurrentUserId().toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("${authService.getCurrentUserName().toString()} Notes"),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewNote(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: notesDatabase.stream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                leading: Checkbox(
                  value: note.isDone,
                  onChanged: (value) {
                    notesDatabase.updateStatus(note, value ?? false);
                  },
                ),
                title: Text(note.title),
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: note.isDone ? TextDecoration.lineThrough : null,
                ),
                subtitle: Text(note.content),
                subtitleTextStyle: TextStyle(
                  decoration: note.isDone ? TextDecoration.lineThrough : null,
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => updateNote(note),
                        icon: const Icon(Icons.edit),
                        color: Colors.amberAccent,
                      ),
                      IconButton(
                        onPressed: () => deleteNote(note),
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent,
                      ),
                    ],
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
