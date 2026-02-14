class Note {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(Map<dynamic, dynamic> map) {
    final rawUpdated = map['updatedAt'];
    final updatedMs = rawUpdated is int
        ? rawUpdated
        : int.tryParse(rawUpdated?.toString() ?? '') ??
              DateTime.now().millisecondsSinceEpoch;

    return Note(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedMs),
    );
  }
}
