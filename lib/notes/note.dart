class Note {
  int? id;
  String userId;
  String title;
  String content;
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
