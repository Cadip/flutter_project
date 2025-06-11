import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  bool isDone;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isDone,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      isDone: map['is_done'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'is_done': isDone,
    };
  }
}
